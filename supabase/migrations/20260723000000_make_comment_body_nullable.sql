alter table public.comments
  alter column body drop not null,
  drop constraint if exists comments_body_check;
