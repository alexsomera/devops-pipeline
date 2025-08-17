export interface Photos {
    id: number;
    albumId: number;
    title: string;
    url: string;
    thumbnailUrl: string;
}

export async function fetchPhotos(): Promise<Photos[]> {
    const response = await fetch('https://jsonplaceholder.typicode.com/photos');
    const data = await response.json();
    return data;
}