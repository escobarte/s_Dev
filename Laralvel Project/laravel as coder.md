### Step 0: Identifying the project, and if we are in root of Laravel
```
cd /var/www/laravel  # если у тебя другой путь — зайди в него
# подсказка: часто это /var/www/html или /var/www/<имя_проекта>
# проверь, что мы в корне Laravel:
pwd
ls -la artisan composer.json .env 2>/dev/null
php artisan --version
Если не уверен в пути, попробуй быстро найти:
sudo find /var/www -maxdepth 3 -type f -name artisan 2>/dev/null
```

### Step 1: Check DB connection and closure (no change)

cd /var/www/app02
# 1) Подключение к БД (ничего не меняет)
sudo -u www-data php artisan migrate:status
# 2) Проверим, какой драйвер PDO доступен (mysql/pgsql)
php -m | grep -E 'pdo_mysql|pdo_pgsql' || true
# 3) Версия PHP (на всякий)
php -v


### Step 2: создаём сущность блога Post (модель + миграция)
cd /var/www/app02
sudo -u www-data php artisan make:model Post -m
ls -1 database/migrations | tail -n 5
```
0001_01_01_000000_create_users_table.php
0001_01_01_000001_create_cache_table.php
0001_01_01_000002_create_jobs_table.php
2025_08_13_130915_create_posts_table.php
```
nano database/migrations/2025_08_13_130915_create_posts_table.php
```
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('slug')->unique();
            $table->text('excerpt')->nullable();
            $table->longText('body');
            $table->timestamp('published_at')->nullable();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('posts');
    }
};
````
sudo -u www-data php artisan migrate
