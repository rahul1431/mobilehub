<?php
namespace App\Policies;

use App\Models\ChitGroup;
use App\Models\User;

class ChitGroupPolicy
{
    public function view(User $user, ChitGroup $group): bool
    {
        return $user->isSuperAdmin() || $group->provider_id === $user->id;
    }

    public function update(User $user, ChitGroup $group): bool
    {
        return $user->isSuperAdmin() || $group->provider_id === $user->id;
    }

    public function delete(User $user, ChitGroup $group): bool
    {
        return $user->isSuperAdmin() || $group->provider_id === $user->id;
    }
}
