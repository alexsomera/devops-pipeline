export interface Album {
    id: number;
    userId: number;
    title: string;
}

export async function fetchAlbums(): Promise<Album[]> {
    const response = await fetch('https://jsonplaceholder.typicode.com/albums');
    const data = await response.json();
    return data;
}