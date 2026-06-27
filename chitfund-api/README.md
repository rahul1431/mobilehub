# Apna Saving — Laravel API Backend

API for the **Apna Saving** Digital Chit Fund app.
Hosted at: `https://chit.myonlinejoker.com`

---

## Requirements

- PHP 8.2+
- MySQL 8.0+
- Composer 2.x
- (Optional) Redis for faster queues

---

## Deployment on cPanel / Shared Hosting

### Step 1 — Upload files
Upload all files in this folder to your hosting domain root (or subdomain root).
Set the document root to the `/public` folder in cPanel.

### Step 2 — Configure .env
```bash
cp .env.example .env
```
Edit `.env` and fill in:
- `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`
- `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`
- `MSG91_API_KEY`, `MSG91_SENDER_ID`, `MSG91_WHATSAPP_SOURCE`
- `FCM_PROJECT_ID`, `FIREBASE_CREDENTIALS_PATH`
- `DIGIO_API_KEY`, `DIGIO_API_SECRET`
- `PUSHER_APP_ID`, `PUSHER_APP_KEY`, `PUSHER_APP_SECRET`
- `APP_URL=https://chit.myonlinejoker.com`

### Step 3 — Install dependencies
```bash
composer install --no-dev --optimize-autoloader
```

### Step 4 — Generate app key & migrate
```bash
php artisan key:generate
php artisan migrate --seed
php artisan storage:link
```

### Step 5 — Set up cron (cPanel → Cron Jobs)
```
* * * * * php /home/YOUR_CPANEL_USER/public_html/artisan schedule:run >> /dev/null 2>&1
```

### Step 6 — Set permissions
```bash
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

---

## API Base URL
`https://chit.myonlinejoker.com/api`

## Authentication
All protected routes require:
```
Authorization: Bearer {sanctum_token}
```

## Roles
- `super_admin` — platform owner
- `chit_provider` — chit agent/foreman
- `chit_member` — end member/subscriber
