# 🔌 API Integration Patterns

### HTTP Client Configuration

#### Base API Client
```typescript
// services/api.ts
import axios from 'axios';

const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for authentication
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('tuvens_auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response?.status === 401) {
      // Redirect to login
      window.location.href = '/auth/login';
    }
    return Promise.reject(error.response?.data || error);
  }
);

export { apiClient };
```

#### Service Layer Pattern
```typescript
// services/events.ts
export class EventsService {
  private static readonly BASE_PATH = '/api/events';

  static async getEvents(params?: EventsQueryParams): Promise<Event[]> {
    const response = await apiClient.get(this.BASE_PATH, { params });
    return response.data;
  }

  static async getEvent(id: string): Promise<Event> {
    const response = await apiClient.get(`${this.BASE_PATH}/${id}`);
    return response.data;
  }

  static async createEvent(eventData: CreateEventData): Promise<Event> {
    const response = await apiClient.post(this.BASE_PATH, eventData);
    return response.data;
  }

  static async updateEvent(id: string, eventData: UpdateEventData): Promise<Event> {
    const response = await apiClient.patch(`${this.BASE_PATH}/${id}`, eventData);
    return response.data;
  }

  static async deleteEvent(id: string): Promise<void> {
    await apiClient.delete(`${this.BASE_PATH}/${id}`);
  }

  // Cross-app integration methods
  static async enableTicketing(eventId: string, ticketingData: TicketingData): Promise<TicketingResult> {
    const response = await apiClient.post(`${this.BASE_PATH}/${eventId}/ticketing`, ticketingData);
    return response.data;
  }
}
```

### State Management Integration

#### React Query Integration
```typescript
// hooks/useEvents.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { EventsService } from '../services/events';

export const useEvents = (params?: EventsQueryParams) => {
  return useQuery({
    queryKey: ['events', params],
    queryFn: () => EventsService.getEvents(params),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};

export const useEvent = (id: string) => {
  return useQuery({
    queryKey: ['events', id],
    queryFn: () => EventsService.getEvent(id),
    enabled: !!id,
  });
};

export const useCreateEvent = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: EventsService.createEvent,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['events'] });
    },
  });
};

export const useEnableTicketing = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ eventId, ticketingData }: { eventId: string; ticketingData: TicketingData }) =>
      EventsService.enableTicketing(eventId, ticketingData),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['events', variables.eventId] });
    },
  });
};
```

#### Zustand Store Pattern
```typescript
// stores/authStore.ts
import { create } from 'zustand';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => void;
  refreshToken: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isAuthenticated: false,
  isLoading: false,

  login: async (credentials) => {
    set({ isLoading: true });
    try {
      const response = await AuthService.login(credentials);
      const { user, token } = response;
      
      localStorage.setItem('tuvens_auth_token', token);
      set({ user, isAuthenticated: true, isLoading: false });
    } catch (error) {
      set({ isLoading: false });
      throw error;
    }
  },

  logout: () => {
    localStorage.removeItem('tuvens_auth_token');
    set({ user: null, isAuthenticated: false });
  },

  refreshToken: async () => {
    try {
      const response = await AuthService.refreshToken();
      const { user, token } = response;
      
      localStorage.setItem('tuvens_auth_token', token);
      set({ user, isAuthenticated: true });
    } catch (error) {
      get().logout();
      throw error;
    }
  },
}));
```