import React from 'react';
import renderer from 'react-test-renderer';
import Index from '../app/index';

// Mocks necessários para o teste do componente Index
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

jest.mock('../components/SearchBar', () => 'SearchBar');

jest.mock('../ViewModel/UsersViewModel', () => ({
  useUsersViewModel: jest.fn(() => ({
    filteredUsers: [],
    searchQuery: '',
    setSearchQuery: jest.fn(),
  })),
}));

describe('App', () => {
  it('renders correctly', () => {
    const tree = renderer.create(<Index />).toJSON();
    expect(tree).toMatchSnapshot();
  });
});
