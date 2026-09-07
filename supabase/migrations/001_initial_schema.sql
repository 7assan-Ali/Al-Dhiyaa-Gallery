-- Al-Dhiyaa Gallery - Supabase/PostgreSQL foundation schema
-- Retail POS + inventory + customer/supplier balances

create extension if not exists pgcrypto;

create type public.user_role as enum ('owner','employee');
create type public.payment_type as enum ('cash','credit');
create type public.sale_status as enum ('completed','cancelled','returned');
create type public.inventory_movement_type as enum ('purchase','sale','sale_return','purchase_return','adjustment');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone text,
  role public.user_role not null default 'employee',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  created_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category_id uuid references public.categories(id) on delete set null,
  description text,
  image_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  variant_name text not null,
  barcode text not null unique,
  base_price numeric(12,2) not null check (base_price >= 0),
  min_stock numeric(12,3) not null default 0 check (min_stock >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(product_id, variant_name)
);

create table public.inventory (
  variant_id uuid primary key references public.product_variants(id) on delete cascade,
  quantity numeric(12,3) not null default 0 check (quantity >= 0),
  updated_at timestamptz not null default now()
);

create table public.suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text,
  notes text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text,
  address text,
  notes text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.purchases (
  id uuid primary key default gen_random_uuid(),
  invoice_number text not null unique,
  supplier_id uuid not null references public.suppliers(id) on delete restrict,
  subtotal numeric(12,2) not null default 0 check (subtotal >= 0),
  total numeric(12,2) not null default 0 check (total >= 0),
  paid_amount numeric(12,2) not null default 0 check (paid_amount >= 0),
  remaining_amount numeric(12,2) generated always as (greatest(total - paid_amount, 0)) stored,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  check (paid_amount <= total)
);

create table public.purchase_items (
  id uuid primary key default gen_random_uuid(),
  purchase_id uuid not null references public.purchases(id) on delete cascade,
  variant_id uuid not null references public.product_variants(id) on delete restrict,
  quantity numeric(12,3) not null check (quantity > 0),
  unit_cost numeric(12,2) not null check (unit_cost >= 0),
  total numeric(12,2) generated always as (quantity * unit_cost) stored
);

create table public.sales (
  id uuid primary key default gen_random_uuid(),
  invoice_number bigint generated always as identity unique,
  customer_id uuid references public.customers(id) on delete set null,
  payment_type public.payment_type not null,
  subtotal numeric(12,2) not null default 0 check (subtotal >= 0),
  discount numeric(12,2) not null default 0 check (discount >= 0),
  total numeric(12,2) not null default 0 check (total >= 0),
  paid_amount numeric(12,2) not null default 0 check (paid_amount >= 0),
  remaining_amount numeric(12,2) generated always as (greatest(total - paid_amount, 0)) stored,
  status public.sale_status not null default 'completed',
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  check (paid_amount <= total)
);

create table public.sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references public.sales(id) on delete cascade,
  variant_id uuid not null references public.product_variants(id) on delete restrict,
  quantity numeric(12,3) not null check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  unit_cost numeric(12,2) not null check (unit_cost >= 0),
  total numeric(12,2) generated always as (quantity * unit_price) stored,
  returned_quantity numeric(12,3) not null default 0 check (returned_quantity >= 0 and returned_quantity <= quantity)
);

create table public.customer_payments (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete restrict,
  sale_id uuid references public.sales(id) on delete set null,
  amount numeric(12,2) not null check (amount > 0),
  payment_method text not null default 'cash',
  notes text,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.supplier_payments (
  id uuid primary key default gen_random_uuid(),
  supplier_id uuid not null references public.suppliers(id) on delete restrict,
  purchase_id uuid references public.purchases(id) on delete set null,
  amount numeric(12,2) not null check (amount > 0),
  payment_method text not null default 'cash',
  notes text,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.sales_returns (
  id uuid primary key default gen_random_uuid(),
  return_number bigint generated always as identity unique,
  sale_id uuid not null references public.sales(id) on delete restrict,
  customer_id uuid references public.customers(id) on delete set null,
  total numeric(12,2) not null default 0 check (total >= 0),
  refund_amount numeric(12,2) not null default 0 check (refund_amount >= 0),
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  notes text
);

create table public.sales_return_items (
  id uuid primary key default gen_random_uuid(),
  return_id uuid not null references public.sales_returns(id) on delete cascade,
  sale_item_id uuid not null references public.sale_items(id) on delete restrict,
  variant_id uuid not null references public.product_variants(id) on delete restrict,
  quantity numeric(12,3) not null check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  total numeric(12,2) generated always as (quantity * unit_price) stored
);

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  category text not null,
  amount numeric(12,2) not null check (amount > 0),
  description text,
  expense_date date not null default current_date,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.inventory_movements (
  id uuid primary key default gen_random_uuid(),
  variant_id uuid not null references public.product_variants(id) on delete restrict,
  movement_type public.inventory_movement_type not null,
  quantity numeric(12,3) not null check (quantity <> 0),
  unit_cost numeric(12,2) check (unit_cost is null or unit_cost >= 0),
  reference_type text,
  reference_id uuid,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  notes text
);

create table public.settings (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

insert into public.settings(key, value) values
  ('credit_markup_percentage', '30'),
  ('currency', 'EGP'),
  ('store_name', 'الضياء'),
  ('invoice_prefix', 'DIA')
on conflict (key) do nothing;

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  old_data jsonb,
  new_data jsonb,
  created_at timestamptz not null default now()
);

create index idx_products_category on public.products(category_id);
create index idx_variants_product on public.product_variants(product_id);
create index idx_variants_barcode on public.product_variants(barcode);
create index idx_sales_customer_date on public.sales(customer_id, created_at desc);
create index idx_sales_created_at on public.sales(created_at desc);
create index idx_sale_items_sale on public.sale_items(sale_id);
create index idx_sale_items_variant on public.sale_items(variant_id);
create index idx_purchases_supplier_date on public.purchases(supplier_id, created_at desc);
create index idx_purchase_items_purchase on public.purchase_items(purchase_id);
create index idx_inventory_movements_variant_date on public.inventory_movements(variant_id, created_at desc);
create index idx_customer_payments_customer_date on public.customer_payments(customer_id, created_at desc);
create index idx_supplier_payments_supplier_date on public.supplier_payments(supplier_id, created_at desc);
create index idx_expenses_date on public.expenses(expense_date desc);

-- Initialize inventory rows for every active variant.
create or replace function public.ensure_inventory_row()
returns trigger language plpgsql security definer as $$
begin
  insert into public.inventory(variant_id, quantity)
  values (new.id, 0)
  on conflict (variant_id) do nothing;
  return new;
end;
$$;

create trigger trg_variant_inventory
after insert on public.product_variants
for each row execute function public.ensure_inventory_row();

-- Price helper: credit price is always base price + configured 30% markup.
create or replace function public.credit_price(base numeric)
returns numeric language sql stable as $$
  select round(base * (1 + coalesce((select value::numeric from public.settings where key = 'credit_markup_percentage'), 30) / 100), 2);
$$;

-- Keep updated_at fields current.
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create trigger trg_products_updated_at before update on public.products for each row execute function public.set_updated_at();
create trigger trg_variants_updated_at before update on public.product_variants for each row execute function public.set_updated_at();
create trigger trg_customers_updated_at before update on public.customers for each row execute function public.set_updated_at();
create trigger trg_suppliers_updated_at before update on public.suppliers for each row execute function public.set_updated_at();

-- Useful reporting views.
create or replace view public.low_stock_products as
select
  pv.id as variant_id,
  p.name as product_name,
  pv.variant_name,
  pv.barcode,
  coalesce(i.quantity, 0) as quantity,
  pv.min_stock,
  pv.base_price
from public.product_variants pv
join public.products p on p.id = pv.product_id
left join public.inventory i on i.variant_id = pv.id
where pv.is_active = true and coalesce(i.quantity, 0) <= pv.min_stock;

create or replace view public.customer_balances as
select
  c.id,
  c.name,
  c.phone,
  coalesce((select sum(s.remaining_amount) from public.sales s where s.customer_id = c.id and s.status = 'completed'), 0)
  - coalesce((select sum(cp.amount) from public.customer_payments cp where cp.customer_id = c.id), 0) as balance
from public.customers c;

create or replace view public.supplier_balances as
select
  s.id,
  s.name,
  s.phone,
  coalesce((select sum(p.remaining_amount) from public.purchases p where p.supplier_id = s.id), 0)
  - coalesce((select sum(sp.amount) from public.supplier_payments sp where sp.supplier_id = s.id), 0) as balance
from public.suppliers s;

create or replace view public.sales_profit as
select
  s.id as sale_id,
  s.invoice_number,
  s.created_at,
  s.payment_type,
  sum(si.total) as revenue,
  sum(si.quantity * si.unit_cost) as cost,
  sum(si.total - (si.quantity * si.unit_cost)) as gross_profit
from public.sales s
join public.sale_items si on si.sale_id = s.id
where s.status = 'completed'
group by s.id, s.invoice_number, s.created_at, s.payment_type;

-- Row-level security foundation. Production deployment should add role-specific policies.
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.product_variants enable row level security;
alter table public.inventory enable row level security;
alter table public.suppliers enable row level security;
alter table public.customers enable row level security;
alter table public.purchases enable row level security;
alter table public.purchase_items enable row level security;
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;
alter table public.customer_payments enable row level security;
alter table public.supplier_payments enable row level security;
alter table public.sales_returns enable row level security;
alter table public.sales_return_items enable row level security;
alter table public.expenses enable row level security;
alter table public.inventory_movements enable row level security;
alter table public.settings enable row level security;
alter table public.audit_logs enable row level security;
