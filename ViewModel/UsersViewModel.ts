import { useState, useEffect } from 'react';
import { User, fetchUsers } from '../Model/UserModel';

export function useUsersViewModel() {
    const [users, setUsers] = useState<User[]>([]);
    const [filteredUsers, setFilteredUsers] = useState<User[]>([]);
    const [selectedIndex, setSelectedIndex] = useState<number | null>(null);
    const [searchQuery, setSearchQuery] = useState<string>('');

    useEffect(() => {
        async function loadUsers() {
            const users = await fetchUsers();
            setUsers(users);
            setFilteredUsers(users);
        }
        loadUsers();
    }, []);

    useEffect(() => {
        const filtered = users.filter(user =>
            user.name.toLowerCase().includes(searchQuery.toLowerCase())
        );
        setFilteredUsers(filtered);
    }, [searchQuery, users]);

    return {
        users,
        filteredUsers,
        selectedIndex,
        searchQuery,
        setSelectedIndex,
        setSearchQuery,
    };
}