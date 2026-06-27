<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GroupMembership extends Model
{
    protected $fillable = ['group_id', 'member_id', 'membership_no', 'has_won', 'is_active', 'mandate_id'];
    protected $casts = ['has_won' => 'boolean', 'is_active' => 'boolean'];

    public function group()  { return $this->belongsTo(ChitGroup::class); }
    public function member() { return $this->belongsTo(User::class, 'member_id'); }
}
