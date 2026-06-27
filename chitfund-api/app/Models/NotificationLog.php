<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NotificationLog extends Model
{
    protected $fillable = ['user_id', 'channel', 'message_type', 'payload', 'status'];

    protected $casts = ['payload' => 'array'];

    public function user() { return $this->belongsTo(User::class); }
}
