drop trigger if exists profiles_updated_at on public.profiles;
drop trigger if exists posts_updated_at on public.posts;
drop trigger if exists comments_updated_at on public.comments;
drop trigger if exists on_auth_user_created on auth.users;
drop trigger if exists comments_identity_immutable on public.comments;
drop trigger if exists posts_no_draft_images on public.posts;
drop trigger if exists posts_no_media_delete on public.posts;
drop trigger if exists comments_no_media_delete on public.comments;
drop policy if exists post_images_storage_select on storage.objects;
drop policy if exists post_images_storage_insert on storage.objects;
drop policy if exists post_images_storage_delete on storage.objects;
drop policy if exists post_images_storage_update on storage.objects;
drop policy if exists comment_images_storage_insert on storage.objects;
drop policy if exists comment_images_storage_delete on storage.objects;
drop policy if exists profiles_select on public.profiles;
drop policy if exists profiles_insert on public.profiles;
drop policy if exists profiles_update on public.profiles;
drop policy if exists posts_select on public.posts;
drop policy if exists posts_insert on public.posts;
drop policy if exists posts_update on public.posts;
drop policy if exists posts_delete on public.posts;
drop policy if exists post_images_select on public.post_images;
drop policy if exists post_images_insert on public.post_images;
drop policy if exists post_images_update on public.post_images;
drop policy if exists post_images_delete on public.post_images;
drop policy if exists comments_select on public.comments;
drop policy if exists comments_insert on public.comments;
drop policy if exists comments_update on public.comments;
drop policy if exists comments_delete on public.comments;
drop policy if exists comment_images_select on public.comment_images;
drop policy if exists comment_images_insert on public.comment_images;
drop policy if exists comment_images_delete on public.comment_images;
drop function if exists public.validate_post_image_upload(text, uuid);
drop function if exists public.validate_comment_image_upload(text, uuid);
drop function if exists public.validate_post_image_metadata_insert(text, bigint, uuid);
drop function if exists public.validate_comment_image_metadata_insert(text, bigint, uuid);
drop function if exists public.authorize_post_object_delete(text, text, uuid);
drop function if exists public.authorize_comment_object_delete(text, text, uuid);
drop function if exists public.authorize_comment_delete(bigint, uuid);
drop function if exists public.lock_post_for_media(bigint);
drop function if exists public.lock_media_parent_post(bigint);
drop function if exists public.owned_post_storage_object(text, uuid);
drop function if exists public.owned_comment_storage_object(text, uuid);
drop function if exists public.prevent_draft_with_images();
drop function if exists public.prevent_post_delete_with_media();
drop function if exists public.prevent_comment_delete_with_media();

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  display_name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.posts (
  id bigint generated always as identity primary key,
  author_id uuid not null default auth.uid()
    references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 200),
  excerpt text not null default '',
  content text not null check (char_length(content) > 0),
  status text not null default 'published'
    check (status in ('draft', 'published')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.post_images (
  id bigint generated always as identity primary key,
  post_id bigint not null references public.posts(id) on delete cascade,
  storage_path text not null unique,
  position integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.comments (
  id bigint generated always as identity primary key,
  post_id bigint not null references public.posts(id) on delete cascade,
  author_id uuid not null default auth.uid()
    references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 5000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.comment_images (
  id bigint generated always as identity primary key,
  comment_id bigint not null references public.comments(id) on delete cascade,
  storage_path text not null unique,
  position integer not null default 0 check (position >= 0),
  created_at timestamptz not null default now()
);

create index if not exists profiles_username_idx on public.profiles(username);
create index if not exists posts_author_id_idx on public.posts(author_id);
create index if not exists posts_created_at_idx on public.posts(created_at desc);
create index if not exists post_images_post_id_idx on public.post_images(post_id);
create index if not exists comments_post_id_created_at_idx
  on public.comments(post_id, created_at);
create index if not exists comments_author_id_idx on public.comments(author_id);
create index if not exists comment_images_comment_position_id_idx
  on public.comment_images(comment_id, position, id);
create index if not exists posts_published_created_at_id_idx
  on public.posts(created_at desc, id desc) where status = 'published';
create index if not exists post_images_post_position_id_idx
  on public.post_images(post_id, position, id);
create index if not exists comments_post_created_at_id_idx
  on public.comments(post_id, created_at, id);

create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = public as $$
begin new.updated_at = now(); return new; end;
$$;

create trigger profiles_updated_at before update on public.profiles
for each row execute function public.set_updated_at();
create trigger posts_updated_at before update on public.posts
for each row execute function public.set_updated_at();
create trigger comments_updated_at before update on public.comments
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, username, display_name)
  values (new.id, new.raw_user_meta_data ->> 'username',
          coalesce(new.raw_user_meta_data ->> 'display_name',
                   split_part(coalesce(new.email, ''), '@', 1)))
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.prevent_comment_identity_change()
returns trigger language plpgsql set search_path = public as $$
begin
  if new.author_id is distinct from old.author_id
     or new.post_id is distinct from old.post_id then
    raise exception 'Comment author and post cannot be changed';
  end if;
  return new;
end;
$$;

create trigger comments_identity_immutable before update of author_id, post_id
on public.comments for each row execute function public.prevent_comment_identity_change();

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.post_images enable row level security;
alter table public.comments enable row level security;
alter table public.comment_images enable row level security;

create policy profiles_select on public.profiles for select to anon, authenticated
using (true);
create policy profiles_insert on public.profiles for insert to authenticated
with check ((select auth.uid()) = id);
create policy profiles_update on public.profiles for update to authenticated
using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

create policy posts_select on public.posts for select to anon, authenticated
using (status = 'published' or (select auth.uid()) = author_id);
create policy posts_insert on public.posts for insert to authenticated
with check ((select auth.uid()) = author_id);
create policy posts_update on public.posts for update to authenticated
using ((select auth.uid()) = author_id)
with check ((select auth.uid()) = author_id);
create policy posts_delete on public.posts for delete to authenticated
using ((select auth.uid()) = author_id);

create policy post_images_select on public.post_images
for select to anon, authenticated using (exists (
  select 1 from public.posts p
  where p.id = post_id and p.status = 'published'
));
create policy post_images_insert on public.post_images for insert to authenticated
with check (exists (
  select 1 from public.posts p
  where p.id = post_id and p.status = 'published'
    and p.author_id = (select auth.uid())
));
create policy post_images_update on public.post_images for update to authenticated
using (exists (select 1 from public.posts p
  where p.id = post_id and p.author_id = (select auth.uid())))
with check (exists (select 1 from public.posts p
  where p.id = post_id and p.author_id = (select auth.uid())));
create policy post_images_delete on public.post_images for delete to authenticated
using (exists (select 1 from public.posts p
  where p.id = post_id and p.author_id = (select auth.uid())));

create policy comments_select on public.comments for select to anon, authenticated
using (exists (select 1 from public.posts p where p.id = post_id
  and (p.status = 'published' or p.author_id = (select auth.uid()))));
create policy comments_insert on public.comments for insert to authenticated
with check ((select auth.uid()) = author_id and exists
  (select 1 from public.posts p where p.id = post_id
    and (p.status = 'published' or p.author_id = (select auth.uid()))));
create policy comments_update on public.comments for update to authenticated
using ((select auth.uid()) = author_id and exists
  (select 1 from public.posts p where p.id = post_id
    and (p.status = 'published' or p.author_id = (select auth.uid()))))
with check ((select auth.uid()) = author_id and exists
  (select 1 from public.posts p where p.id = post_id
    and (p.status = 'published' or p.author_id = (select auth.uid()))));
create policy comments_delete on public.comments for delete to authenticated
using (
  (select auth.uid()) = author_id
  and exists (
    select 1 from public.posts p
    where p.id = post_id
      and (p.status = 'published' or p.author_id = (select auth.uid()))
  )
);

create policy comment_images_select on public.comment_images
for select to anon, authenticated using (exists (
  select 1 from public.comments c
  join public.posts p on p.id = c.post_id
  where c.id = comment_id and p.status = 'published'
));
create policy comment_images_insert on public.comment_images for insert to authenticated
with check (exists (
  select 1 from public.comments c
  join public.posts p on p.id = c.post_id
  where c.id = comment_id
    and c.author_id = (select auth.uid())
    and p.status = 'published'
));
create policy comment_images_delete on public.comment_images for delete to authenticated
using (exists (
  select 1 from public.comments c
  join public.posts p on p.id = c.post_id
  where c.id = comment_id
    and (c.author_id = (select auth.uid()) or p.author_id = (select auth.uid()))
));

grant select on public.profiles, public.posts, public.post_images,
  public.comments, public.comment_images to anon, authenticated;
grant insert, update, delete on public.profiles, public.posts,
  public.post_images, public.comments, public.comment_images to authenticated;
grant usage, select on all sequences in schema public to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('post-images', 'post-images', true, 10485760,
        array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy post_images_storage_select on storage.objects
for select to anon, authenticated
using (bucket_id = 'post-images');

create policy post_images_storage_insert on storage.objects
for insert to authenticated
with check (
  bucket_id = 'post-images'
  and owner_id = (select auth.uid())::text
);

create policy post_images_storage_delete on storage.objects
for delete to authenticated
using (
  bucket_id = 'post-images'
  and owner_id = (select auth.uid())::text
);
