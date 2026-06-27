<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, SoftDeletes;

    protected $fillable = [
        'phone', 'full_name', 'email', 'role',
        'provider_id', 'kyc_status', 'fcm_token',
        'preferred_lang', 'referral_code', 'referred_by',
    ];

    protected $hidden = ['remember_token'];

    protected $casts = ['email_verified_at' => 'datetime'];

    // Relationships
    public function provider()       { return $this->belongsTo(User::class, 'provider_id'); }
    public function referredBy()     { return $this->belongsTo(User::class, 'referred_by'); }
    public function memberships()    { return $this->hasMany(GroupMembership::class, 'member_id'); }
    public function providerGroups() { return $this->hasMany(ChitGroup::class, 'provider_id'); }
    public function payments()       { return $this->hasMany(Payment::class, 'member_id'); }
    public function kycDocuments()   { return $this->hasMany(KycDocument::class, 'member_id'); }
    public function subscription()   { return $this->hasOne(ProviderSubscription::class)->latestOfMany(); }

    // Helpers
    public function isSuperAdmin()  { return $this->role === 'super_admin'; }
    public function isProvider()    { return $this->role === 'chit_provider'; }
    public function isMember()      { return $this->role === 'chit_member'; }
    public function isKycVerified() { return $this->kyc_status === 'verified'; }

    public function canCreateGroup(): bool
    {
        if ($this->isSuperAdmin()) return true;
        $sub = $this->subscription;
        if (!$sub || $sub->status !== 'active') return false;
        $activeGroups = $this->providerGroups()->whereIn('status', ['forming', 'active'])->count();
        return $sub->plan->group_limit === -1 || $activeGroups < $sub->plan->group_limit;
    }
}
