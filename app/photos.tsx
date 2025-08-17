import React from 'react';
import { Text, View, FlatList, TouchableOpacity, Image, StyleSheet } from "react-native";
import { useRouter, useLocalSearchParams } from "expo-router";
import { commonStyles } from "../assets/styles";
import { usePhotosViewModel } from "../ViewModel/PhotosViewModel";
import SearchBar from "../components/SearchBar";

export default function Photos() {
    const router = useRouter();
    const { albumId } = useLocalSearchParams();
    const albumIdString = Array.isArray(albumId) ? albumId[0] : albumId;
    const {
        filteredPhotos,
        searchQuery,
        setSearchQuery,
    } = usePhotosViewModel(albumIdString);

    const handlePhotoClick = (photoUrl: string, photoTitle: string) => {
        router.push(`/photo?photoUrl=${photoUrl}&photoTitle=${encodeURIComponent(photoTitle)}`);
    };

    return (
        <FlatList
            contentContainerStyle={commonStyles.container}
            ListHeaderComponent={
                <>
                    <Text style={commonStyles.title}>Selecione uma foto</Text>
                    <SearchBar
                        searchQuery={searchQuery}
                        setSearchQuery={setSearchQuery}
                        placeholder="Pesquisar fotos..."
                    />
                </>
            }
            data={filteredPhotos}
            keyExtractor={(item) => item.id.toString()}
            numColumns={3}
            renderItem={({ item }) => (
                <TouchableOpacity onPress={() => handlePhotoClick(item.url, item.title)} style={commonStyles.itemContainer}>
                    <View style={commonStyles.item}>
                        <Image
                            source={{ uri: item.thumbnailUrl }}
                            style={commonStyles.image}
                        />
                        <Text style={commonStyles.thumbTitle}>{item.title}</Text>
                    </View>
                </TouchableOpacity>
            )}
            
        />
    );
}