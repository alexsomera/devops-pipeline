import { useState, useEffect } from 'react';
import { Photos, fetchPhotos } from '../Model/PhotosModel';

export function usePhotosViewModel(albumId: string) {
  const [photos, setPhotos] = useState<Photos[]>([]);
  const [filteredPhotos, setFilteredPhotos] = useState<Photos[]>([]);
  const [searchQuery, setSearchQuery] = useState<string>('');

  useEffect(() => {
    async function loadPhotos() {
      try {
        const photos = await fetchPhotos();
        const updatedPhotos = photos.map(photo => ({
          ...photo,
          thumbnailUrl: photo.thumbnailUrl.replace('via.placeholder.com', 'dummyimage.com'),
          url: photo.url.replace('via.placeholder.com', 'dummyimage.com')
        }));
        setPhotos(updatedPhotos);
        // Filter photos by album ID
        const albumPhotos = updatedPhotos.filter(photo => photo.albumId === parseInt(albumId));
        setFilteredPhotos(albumPhotos);
      } catch (e) {
        console.error('Falha ao carregar fotos:', e);
      }
    }
    loadPhotos();
  }, [albumId]);

  useEffect(() => {
    // Filter photos based on search query
    const filtered = photos.filter(photo =>
      photo.title.toLowerCase().includes(searchQuery.toLowerCase()) && photo.albumId === parseInt(albumId)
    );
    setFilteredPhotos(filtered);
  }, [searchQuery, photos, albumId]);

  return {
    photos,
    filteredPhotos,
    searchQuery,
    setSearchQuery
  };
}