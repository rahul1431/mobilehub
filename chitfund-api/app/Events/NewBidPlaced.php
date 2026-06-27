<?php
namespace App\Events;

use App\Models\Bid;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class NewBidPlaced implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public Bid $bid) {}

    public function broadcastOn(): Channel
    {
        return new Channel('cycle.' . $this->bid->cycle_id);
    }

    public function broadcastAs(): string
    {
        return 'bid.placed';
    }

    public function broadcastWith(): array
    {
        return [
            'id'         => $this->bid->id,
            'cycle_id'   => $this->bid->cycle_id,
            'member_id'  => $this->bid->member_id,
            'bid_amount' => $this->bid->bid_amount,
            'is_winning' => $this->bid->is_winning,
            'placed_at'  => $this->bid->updated_at?->toISOString(),
        ];
    }
}
