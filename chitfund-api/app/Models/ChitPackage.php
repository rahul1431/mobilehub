<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class ChitPackage extends Model
{
    use SoftDeletes;

    protected $fillable = ['name', 'monthly_amount', 'duration_months', 'max_members', 'commission_pct', 'description', 'is_active', 'created_by'];
    protected $casts = ['monthly_amount' => 'float', 'commission_pct' => 'float', 'is_active' => 'boolean'];

    public function groups()    { return $this->hasMany(ChitGroup::class, 'package_id'); }
    public function creator()   { return $this->belongsTo(User::class, 'created_by'); }
}
