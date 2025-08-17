import { useState, useEffect } from 'react';
import { Album, fetchAlbums } from '../Model/AlbumModel';

export function useAlbumsViewModel(userId: string) {
    const [albums, setAlbums] = useState<Album[]>([]);
    const [filteredAlbums, setFilteredAlbums] = useState<Album[]>([]);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        async function loadAlbums() {
            try {
                // Try to fetch albums
                const albums = await fetchAlbums();
                setAlbums(albums);
                // Filter albums by user ID
                const userAlbums = albums.filter(album => album.userId === parseInt(userId));
                setFilteredAlbums(userAlbums);
            } catch (e) {
                // Handle error
                setError('Falha ao carregar álbuns');
                console.error(e);
            }
        }
        loadAlbums();
    }, [userId]);

    return {
        albums,
        filteredAlbums,
        error,
    };
}