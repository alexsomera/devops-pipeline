import React from 'react';
import { Text, FlatList, TouchableOpacity, Image, View, StyleSheet } from "react-native";
import { useRouter, useLocalSearchParams } from "expo-router";
import { commonStyles } from "../assets/styles";
import { useAlbumsViewModel } from "../ViewModel/AlbumsViewModel";


export default function Albums() {
    const router = useRouter();
    const { id } = useLocalSearchParams();
    const albumId = Array.isArray(id) ? id[0] : id;
    const { filteredAlbums } = useAlbumsViewModel(albumId);

    const handleAlbumClick = (albumId: number) => {
        router.push(`/photos?albumId=${albumId}`);
    };

    return (
        <FlatList
            style={[commonStyles.container, { flex: 1 }]}
            data={filteredAlbums}
            keyExtractor={(item) => item.id.toString()}
            numColumns={2}
            ListHeaderComponent={
                <Text style={commonStyles.title}>Selecione um álbum</Text>
            }
            ListFooterComponent={<View style={{ height: 20 }} />}
            renderItem={({ item }) => (
                <TouchableOpacity onPress={() => handleAlbumClick(item.id)} style={commonStyles.itemContainer}>
                    <View style={commonStyles.item}>
                        <Image source={{ uri: 'https://dummyimage.com/640x360/ccc/aaa' }} style={commonStyles.image} />
                        <Text style={commonStyles.thumbTitle}>{item.title}</Text>
                    </View>
                </TouchableOpacity>
            )}
        />
    );
}