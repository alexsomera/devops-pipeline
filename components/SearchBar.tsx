import React from 'react';
import { View, TextInput } from "react-native";
import { MaterialIcons } from '@expo/vector-icons';

interface SearchBarProps {
    searchQuery: string;
    setSearchQuery: (query: string) => void;
    placeholder: string;
}

export default function SearchBar({ searchQuery, setSearchQuery, placeholder }: SearchBarProps) {
    return (
        <View style={{
            paddingBlock: 5,
            paddingHorizontal: 10,
            marginBottom: 20,
            backgroundColor: '#E9F7FF',
            flexDirection: 'row',
            alignItems: 'center',
            gap: 16,
            outline: 'none',
        }}>
            <MaterialIcons name="search" size={24} color="black" />
            <TextInput
                style={{ flex: 1, height: 60, outline: 'none' }}
                placeholder={placeholder}
                value={searchQuery}
                onChangeText={setSearchQuery}
            />
        </View>
    );
};