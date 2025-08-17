export interface User {
    id: number;
    name: string;
}

export async function fetchUsers(): Promise<User[]> {
    const response = await fetch('https://jsonplaceholder.typicode.com/users');
    const data = await response.json();
    return data;
}