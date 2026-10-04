-- Einmal ausführen: ergänzt die persönliche Kontofreigabe.
-- Bestehende Kurse, Mitglieder, Mitschriften und Nachrichten bleiben erhalten.
begin;
create table if not exists public.uz_requests(
 user_id uuid primary key references auth.users(id) on delete cascade,
 email text not null,name text not null,status text not null default 'pending' check(status in ('pending','approved','rejected')),
 created_at timestamptz not null default now(),decided_at timestamptz
);
alter table public.uz_requests enable row level security;
revoke all on public.uz_requests from anon,authenticated;
grant select on public.uz_requests to authenticated;
drop policy if exists uz_requests_read on public.uz_requests;
create policy uz_requests_read on public.uz_requests for select to authenticated using(public.uz_is_owner() or user_id=auth.uid());
create or replace function public.uz_signup_request() returns trigger language plpgsql security definer set search_path='' as $$begin
 if new.raw_user_meta_data->>'app'='uni-zusammen' and not exists(select 1 from public.uz_workspace where lower(owner_email)=lower(new.email)) then
 insert into public.uz_requests(user_id,email,name) values(new.id,lower(new.email),left(coalesce(nullif(trim(new.raw_user_meta_data->>'name'),''),split_part(new.email,'@',1)),80)) on conflict(user_id) do nothing;
 end if;return new;end $$;
drop trigger if exists uz_signup_request on auth.users;
create trigger uz_signup_request after insert on auth.users for each row execute function public.uz_signup_request();
create or replace function public.uz_bootstrap() returns jsonb language plpgsql security definer set search_path='' as $$
declare u auth.users%rowtype;w public.uz_workspace%rowtype;n text;s text;
begin
 if auth.uid() is null then raise exception 'Bitte anmelden.';end if;
 select * into u from auth.users where id=auth.uid();
 if u.email_confirmed_at is null then raise exception 'Bitte zuerst deine E-Mail-Adresse bestätigen.';end if;
 select * into w from public.uz_workspace where id=1 for update;
 if w.owner_user is null and lower(u.email)=lower(w.owner_email) then update public.uz_workspace set owner_user=u.id where id=1;w.owner_user:=u.id;end if;
 n:=left(coalesce(nullif(trim(u.raw_user_meta_data->>'name'),''),split_part(u.email,'@',1)),80);
 if u.id=w.owner_user then insert into public.uz_members(user_id,name) values(u.id,n) on conflict(user_id) do nothing;end if;
 if exists(select 1 from public.uz_members where user_id=u.id) then return jsonb_build_object('approved',true,'isOwner',public.uz_is_owner(),'userId',u.id);end if;
 insert into public.uz_requests(user_id,email,name) values(u.id,lower(u.email),n) on conflict(user_id) do nothing;
 select status into s from public.uz_requests where user_id=u.id;
 return jsonb_build_object('approved',false,'isOwner',false,'userId',u.id,'status',s,'email',u.email);
end $$;
create or replace function public.uz_list_requests() returns table(user_id uuid,email text,name text,status text,created_at timestamptz,decided_at timestamptz,email_confirmed boolean) language plpgsql security definer set search_path='' as $$begin
 if not public.uz_is_owner() then raise exception 'Nur die Eigentümerin darf Kontoanfragen sehen.';end if;
 return query select r.user_id,r.email,r.name,r.status,r.created_at,r.decided_at,(u.email_confirmed_at is not null) from public.uz_requests r join auth.users u on u.id=r.user_id order by r.created_at desc;
end $$;
create or replace function public.uz_decide_request(request_user uuid,approve boolean) returns void language plpgsql security definer set search_path='' as $$declare r public.uz_requests%rowtype;begin
 if not public.uz_is_owner() then raise exception 'Nur die Eigentümerin darf Konten freigeben.';end if;
 if approve is null then raise exception 'Bitte Freigeben oder Ablehnen wählen.';end if;
 select * into r from public.uz_requests where user_id=request_user for update;
 if not found then raise exception 'Diese Kontoanfrage existiert nicht mehr.';end if;
 if r.status<>'pending' then raise exception 'Diese Anfrage wurde bereits entschieden.';end if;
 if approve then
  if not exists(select 1 from auth.users where id=request_user and email_confirmed_at is not null) then raise exception 'Die Person muss zuerst ihre E-Mail-Adresse bestätigen.';end if;
  insert into public.uz_members(user_id,name) values(r.user_id,r.name) on conflict(user_id) do nothing;
 end if;
 update public.uz_requests set status=case when approve then 'approved' else 'rejected' end,decided_at=now() where user_id=request_user;
end $$;
-- Alte Vorab-Einladungen geben neuen Konten keinen automatischen Zugriff mehr.
revoke execute on function public.uz_allow_email(text) from authenticated;
revoke all on function public.uz_signup_request(),public.uz_bootstrap(),public.uz_list_requests(),public.uz_decide_request(uuid,boolean) from public,anon,authenticated;
grant execute on function public.uz_bootstrap(),public.uz_list_requests(),public.uz_decide_request(uuid,boolean) to authenticated;
commit;
