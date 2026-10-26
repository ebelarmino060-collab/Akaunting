# Akaunting ERD

This diagram is based on the Laravel migrations in `database/migrations` and the
relationships declared by the Eloquent models. The default database prefix is
`ak_`; Mermaid shows logical table names without that prefix.

The migrations use indexes for most application relationships rather than
database-enforced foreign keys. Relationship lines below therefore represent
the application/ORM relationship, not necessarily a physical foreign-key
constraint.

```mermaid
erDiagram
    companies ||--o{ accounts : has
    companies ||--o{ categories : has
    companies ||--o{ contacts : has
    companies ||--o{ currencies : has
    companies ||--o{ dashboards : has
    companies ||--o{ documents : has
    companies ||--o{ document_items : has
    companies ||--o{ document_item_taxes : has
    companies ||--o{ document_histories : has
    companies ||--o{ document_totals : has
    companies ||--o{ email_templates : has
    companies ||--o{ items : has
    companies ||--o{ item_taxes : has
    companies ||--o{ modules : has
    companies ||--o{ module_histories : has
    companies ||--o{ reconciliations : has
    companies ||--o{ recurring : has
    companies ||--o{ reports : has
    companies ||--o{ settings : has
    companies ||--o{ taxes : has
    companies ||--o{ transactions : has
    companies ||--o{ transaction_taxes : has
    companies ||--o{ transfers : has
    companies }o--o{ users : "user_companies"

    users }o--o{ roles : "user_roles"
    roles }o--o{ permissions : "role_permissions"
    users }o--o{ permissions : "user_permissions"
    users }o--o{ dashboards : "user_dashboards"
    users ||--o{ contacts : creates/owns
    users ||--o{ user_invitations : receives
    users ||--o{ notifications : receives

    currencies ||--o{ accounts : currency_code
    currencies ||--o{ contacts : currency_code
    currencies ||--o{ documents : currency_code
    currencies ||--o{ transactions : currency_code

    categories ||--o{ categories : parent_id
    categories ||--o{ contacts : category_id
    categories ||--o{ documents : category_id
    categories ||--o{ items : category_id
    categories ||--o{ transactions : category_id

    contacts ||--o{ contact_persons : has
    contacts ||--o{ documents : billed_to
    contacts ||--o{ transactions : involves

    dashboards ||--o{ widgets : contains

    documents ||--o{ documents : parent_id
    documents ||--o{ document_items : contains
    documents ||--o{ document_item_taxes : taxes
    documents ||--o{ document_histories : history
    documents ||--o{ document_totals : totals
    documents ||--o{ transactions : generates
    items ||--o{ document_items : referenced_by
    taxes ||--o{ document_item_taxes : applied

    accounts ||--o{ transactions : contains
    accounts ||--o{ reconciliations : reconciles
    transactions ||--o{ transactions : parent_id
    transactions ||--o{ transactions : split_id
    transactions ||--o{ transaction_taxes : taxes
    transactions ||--o{ transfers : income/expense

    modules ||--o{ module_histories : history

    bills ||--o{ bill_items : contains
    bills ||--o{ bill_item_taxes : taxes
    bills ||--o{ bill_histories : history
    bills ||--o{ bill_totals : totals
    invoices ||--o{ invoice_items : contains
    invoices ||--o{ invoice_item_taxes : taxes
    invoices ||--o{ invoice_histories : history
    invoices ||--o{ invoice_totals : totals
    items ||--o{ bill_items : referenced_by
    items ||--o{ invoice_items : referenced_by
    taxes ||--o{ bill_item_taxes : applied
    taxes ||--o{ invoice_item_taxes : applied

    companies {
        int id PK
        string domain
        boolean enabled
    }
    users {
        int id PK
        string name
        string email
    }
    roles {
        int id PK
        string name
    }
    permissions {
        int id PK
        string name
    }
    accounts {
        int id PK
        int company_id
        string currency_code
        decimal opening_balance
    }
    currencies {
        int id PK
        int company_id
        string code
        decimal rate
    }
    categories {
        int id PK
        int company_id
        int parent_id
        string type
    }
    contacts {
        int id PK
        int company_id
        int user_id
        string type
        string currency_code
    }
    contact_persons {
        int id PK
        int contact_id
    }
    dashboards {
        int id PK
        int company_id
    }
    widgets {
        int id PK
        int company_id
        int dashboard_id
    }
    documents {
        int id PK
        int company_id
        int contact_id
        int category_id
        int parent_id
        string type
        decimal amount
    }
    document_items {
        int id PK
        int company_id
        int document_id
        int item_id
        decimal quantity
        decimal total
    }
    document_item_taxes {
        int id PK
        int document_id
        int document_item_id
        int tax_id
    }
    document_histories {
        int id PK
        int document_id
        string type
        string status
    }
    document_totals {
        int id PK
        int document_id
        string code
        decimal amount
    }
    items {
        int id PK
        int company_id
        int category_id
        string name
        string sku
    }
    taxes {
        int id PK
        int company_id
        string name
        decimal rate
    }
    transactions {
        int id PK
        int company_id
        int account_id
        int document_id
        int category_id
        int contact_id
        int parent_id
        int split_id
    }
    transaction_taxes {
        int id PK
        int company_id
        int transaction_id
        int tax_id
    }
    transfers {
        int id PK
        int company_id
        int income_transaction_id
        int expense_transaction_id
    }
    reconciliations {
        int id PK
        int company_id
        int account_id
        int ending_balance
    }
    modules {
        int id PK
        int company_id
        string alias
    }
    module_histories {
        int id PK
        int company_id
        int module_id
    }
    recurring {
        int id PK
        int company_id
        string object_type
    }
    reports {
        int id PK
        int company_id
        string name
    }
    settings {
        int id PK
        int company_id
        string key
    }
    email_templates {
        int id PK
        int company_id
        string name
    }
    bills {
        int id PK
        int company_id
        int vendor_id
        int category_id
    }
    bill_items {
        int id PK
        int company_id
        int bill_id
        int item_id
    }
    bill_item_taxes {
        int id PK
        int bill_id
        int bill_item_id
        int tax_id
    }
    bill_histories {
        int id PK
        int company_id
        int bill_id
    }
    bill_totals {
        int id PK
        int company_id
        int bill_id
    }
    invoices {
        int id PK
        int company_id
        int customer_id
        int category_id
    }
    invoice_items {
        int id PK
        int company_id
        int invoice_id
        int item_id
    }
    invoice_item_taxes {
        int id PK
        int invoice_id
        int invoice_item_id
        int tax_id
    }
    invoice_histories {
        int id PK
        int company_id
        int invoice_id
    }
    invoice_totals {
        int id PK
        int company_id
        int invoice_id
    }
    user_companies {
        int user_id PK
        int company_id PK
    }
    user_roles {
        int user_id PK
        int role_id PK
    }
    role_permissions {
        int role_id PK
        int permission_id PK
    }
    user_permissions {
        int user_id PK
        int permission_id PK
    }
    user_dashboards {
        int user_id PK
        int dashboard_id PK
    }
    user_invitations {
        int id PK
        int user_id
        int company_id
    }
    notifications {
        int id PK
        int user_id
        string type
    }
```

Framework/support tables such as `jobs`, `failed_jobs`, `sessions`,
`password_resets`, `personal_access_tokens`, `firewall_ips`, and
`firewall_logs` are intentionally omitted from the business-domain diagram.
