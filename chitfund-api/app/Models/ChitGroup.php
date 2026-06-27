<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class ChitGroup extends Model
{
    use SoftDeletes;

    protected $fillable = ['package_id', 'provider_id', 'name', 'status', 'current_cycle', 'start_date', 'total_members'];

    public function package()     { return $this->belongsTo(ChitPackage::class); }
    public function provider()    { return $this->belongsTo(User::class, 'provider_id'); }
    public function memberships() { return $this->hasMany(GroupMembership::class, 'group_id'); }
    public function members()     { return $this->hasManyThrough(User::class, GroupMembership::class, 'group_id', 'id', 'id', 'member_id'); }
    public function cycles()      { return $this->hasMany(Cycle::class, 'group_id'); }
    public function currentCycle(){ return $this->hasOne(Cycle::class, 'group_id')->where('cycle_number', $this->current_cycle); }

    public function monthlyPot(): float
    {
        return (float) ($this->package->monthly_amount * $this->total_members);
    }
}
