import mockAsyncStorage from '@react-native-async-storage/async-storage/jest/async-storage-mock';

jest.mock('@react-native-async-storage/async-storage', () => mockAsyncStorage);

jest.mock('expo-router', () => ({
  useRouter: jest.fn(() => ({
    push: jest.fn(),
  })),
  useLocalSearchParams: jest.fn(() => ({})),
}));

jest.mock('expo-font', () => ({
  useFonts: jest.fn(() => [true, null]),
  loadAsync: jest.fn(),
}));

jest.mock('@expo/vector-icons', () => ({
  MaterialIcons: 'MaterialIcons',
}));

jest.mock('expo-constants', () => ({
  manifest: {
    extra: {
      eas: {
        projectId: 'your-project-id',
      },
    },
  },
}));

jest.mock('./components/SearchBar', () => 'SearchBar');

jest.mock('./ViewModel/UsersViewModel', () => ({
  useUsersViewModel: jest.fn(() => ({
    filteredUsers: [],
    searchQuery: '',
    setSearchQuery: jest.fn(),
  })),
}));
