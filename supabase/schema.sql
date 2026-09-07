-- Al-Dhiyaa Gallery PostgreSQL / Supabase schema
create extension if not exists pgcrypto;

do $$ begin create type payment_type as enum ('cash','credit'); exception when duplicate_object then null; end $$;
do $$ begin create type movement_type as enum ('purchase','sale','sale_return','purchase_return','adjustment'); exception when duplicate_object then null; end $$;

create table if not exists categories(id uuid primary key default gen_random_uuid(),name text not null unique,description text,created_at timestamptz not null default now());
create table if not exists users(id uuid primary key references auth.users(id) on delete cascade,name text not null,phone text,role text not null default 'employee' check(role in ('owner','employee')),is_active boolean not null default true,created_at timestamptz not null default now());
create table if not exists products(id uuid primary key default gen_random_uuid(),name text not null,category_id uuid references categories(id),description text,is_active boolean not null default true,created_at timestamptz not null default now());
create table if not exists product_variants(id uuid primary key default gen_random_uuid(),product_id uuid not null references products(id) on delete cascade,variant_name text not null default 'قياسي',barcode text not null unique,base_price numeric(12,2) not null default 0 check(base_price>=0),min_stock numeric(12,2) not null default 0 check(min_stock>=0),is_active boolean not null default true,created_at timestamptz not null default now());
create table if not exists inventory(id uuid primary key default gen_random_uuid(),variant_id uuid not null unique references product_variants(id) on delete cascade,quantity numeric(12,2) not null default 0 check(quantity>=0),updated_at timestamptz not null default now());
create table if not exists suppliers(id uuid primary key default gen_random_uuid(),name text not null,phone text,notes text,is_active boolean not null default true,created_at timestamptz not null default now());
create table if not exists customers(id uuid primary key default gen_random_uuid(),name text not null,phone text,address text,notes text,is_active boolean not null default true,created_at timestamptz not null default now());
create table if not exists purchases(id uuid primary key default gen_random_uuid(),invoice_number text not null unique,supplier_id uuid references suppliers(id),subtotal numeric(12,2) not null default 0,total numeric(12,2) not null default 0,paid_amount numeric(12,2) not null default 0,remaining_amount numeric(12,2) generated always as (greatest(total-paid_amount,0)) stored,created_by uuid references users(id),created_at timestamptz not null default now());
create table if not exists purchase_items(id uuid primary key default gen_random_uuid(),purchase_id uuid not null references purchases(id) on delete cascade,variant_id uuid not null references product_variants(id),quantity numeric(12,2) not null check(quantity>0),unit_cost numeric(12,2) not null check(unit_cost>=0),total numeric(12,2) generated always as (quantity*unit_cost) stored);
create table if not exists sales(id uuid primary key default gen_random_uuid(),invoice_number bigint generated always as identity unique,customer_id uuid references customers(id),payment_type payment_type not null default 'cash',subtotal numeric(12,2) not null default 0,discount numeric(12,2) not null default 0,total numeric(12,2) not null default 0,paid_amount numeric(12,2) not null default 0,remaining_amount numeric(12,2) generated always as (greatest(total-paid_amount,0)) stored,created_by uuid references users(id),created_at timestamptz not null default now());
create table if not exists sale_items(id uuid primary key default gen_random_uuid(),sale_id uuid not null references sales(id) on delete cascade,variant_id uuid not null references product_variants(id),quantity numeric(12,2) not null check(quantity>0),unit_price numeric(12,2) not null check(unit_price>=0),unit_cost numeric(12,2) not null check(unit_cost>=0),total numeric(12,2) generated always as (quantity*unit_price) stored,returned_quantity numeric(12,2) not null default 0);
create table if not exists customer_payments(id uuid primary key default gen_random_uuid(),customer_id uuid not null references customers(id),sale_id uuid references sales(id),amount numeric(12,2) not null check(amount>0),payment_method text not null default 'cash',created_by uuid references users(id),created_at timestamptz not null default now(),notes text);
create table if not exists supplier_payments(id uuid primary key default gen_random_uuid(),supplier_id uuid not null references suppliers(id),purchase_id uuid references purchases(id),amount numeric(12,2) not null check(amount>0),created_by uuid references users(id),created_at timestamptz not null default now(),notes text);
create table if not exists inventory_movements(id uuid primary key default gen_random_uuid(),variant_id uuid not null references product_variants(id),movement_type movement_type not null,quantity numeric(12,2) not null,reference_type text,reference_id uuid,unit_cost numeric(12,2),created_by uuid references users(id),created_at timestamptz not null default now(),notes text);
create table if not exists sales_returns(id uuid primary key default gen_random_uuid(),return_number bigint generated always as identity unique,sale_id uuid not null references sales(id),customer_id uuid references customers(id),total numeric(12,2) not null default 0,refund_amount numeric(12,2) not null default 0,created_by uuid references users(id),created_at timestamptz not null default now(),notes text);
create table if not exists sales_return_items(id uuid primary key default gen_random_uuid(),return_id uuid not null references sales_returns(id) on delete cascade,sale_item_id uuid not null references sale_items(id),variant_id uuid not null references product_variants(id),quantity numeric(12,2) not null check(quantity>0),unit_price numeric(12,2) not null check(unit_price>=0),total numeric(12,2) generated always as (quantity*unit_price) stored);
create table if not exists expenses(id uuid primary key default gen_random_uuid(),category text not null,amount numeric(12,2) not null check(amount>=0),description text,expense_date date not null default current_date,created_by uuid references users(id),created_at timestamptz not null default now());
create table if not exists settings(id uuid primary key default gen_random_uuid(),key text not null unique,value text,updated_at timestamptz not null default now());
create table if not exists audit_logs(id uuid primary key default gen_random_uuid(),user_id uuid references users(id),action text not null,entity_type text,entity_id uuid,old_data jsonb,new_data jsonb,created_at timestamptz not null default now());

insert into settings(key,value) values ('credit_markup_percentage','30'),('currency','EGP'),('shop_name','الضياء') on conflict(key) do nothing;
create index if not exists idx_variants_barcode on product_variants(barcode);
create index if not exists idx_movements_variant_date on inventory_movements(variant_id,created_at desc);
create index if not exists idx_sales_date on sales(created_at desc);
create index if not exists idx_sales_customer on sales(customer_id,created_at desc);
create index if not exists idx_purchases_supplier on purchases(supplier_id,created_at desc);

-- Credit price is intentionally calculated from base_price + configurable markup.
create or replace function credit_price(base numeric) returns numeric language sql immutable as $$ select round(base * 1.30,2) $$;

-- Starter RLS. For production, tighten policies according to owner/employee role.
alter table products enable row level security;
alter table product_variants enable row level security;
alter table inventory enable row level security;
alter table customers enable row level security;
alter table sales enable row level security;
alter table sale_items enable row level security;
alter table expenses enable row level security;
create policy "authenticated read products" on products for select to authenticated using (true);
create policy "authenticated write products" on products for all to authenticated using (true) with check (true);
create policy "authenticated read variants" on product_variants for select to authenticated using (true);
create policy "authenticated write variants" on product_variants for all to authenticated using (true) with check (true);
create policy "authenticated inventory" on inventory for all to authenticated using (true) with check (true);
create policy "authenticated customers" on customers for all to authenticated using (true) with check (true);
create policy "authenticated sales" on sales for all to authenticated using (true) with check (true);
create policy "authenticated sale items" on sale_items for all to authenticated using (true) with check (true);
create policy "authenticated expenses" on expenses for all to authenticated using (true) with check (true);
