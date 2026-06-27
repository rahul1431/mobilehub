<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SubscriptionPlan extends Model
{
    protected $fillable = ['name', 'price', 'group_limit', 'member_limit', 'is_active'];
    protected $casts = ['price' => 'float', 'is_active' => 'boolean'];

    public function subscriptions() { return $this->hasMany(ProviderSubscription::class, 'plan_id'); }
}
