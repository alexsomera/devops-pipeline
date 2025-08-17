import React from 'react';
import { Stack } from "expo-router";

export default function RootLayout() {
    return (
        <Stack>
            <Stack.Screen name="index" options={{
                title: 'Usuários',
                headerStyle: { backgroundColor: '#3060c5' },
                headerTintColor: '#fff',
                headerTitleStyle: { fontWeight: '400' },
                headerTitleAlign: 'center'
            }}
            />
            <Stack.Screen name="albums" options={{
                title: 'Álbuns',
                headerStyle: { backgroundColor: '#3060c5' },
                headerTintColor: '#fff',
                headerTitleStyle: { fontWeight: '400' },
                headerTitleAlign: 'center'
            }} />
            <Stack.Screen name="photos" options={{
                headerBackButtonDisplayMode: "minimal",
                title: 'Fotos',
                headerStyle: { backgroundColor: '#3060c5' },
                headerTintColor: '#fff',
                headerTitleStyle: { fontWeight: '400' },
                headerTitleAlign: 'center'
            }} />
            <Stack.Screen name="photo" options={{
                title: 'Foto',
                headerStyle: { backgroundColor: '#3060c5' },
                headerTintColor: '#fff',
                headerTitleStyle: { fontWeight: '400' },
                headerTitleAlign: 'center'
            }} />
        </Stack>
    );
}
