# 🔒 Security Best Practices

### Authentication Security

#### JWT Token Handling
```typescript
// Secure token storage
class TokenManager {
  private static readonly TOKEN_KEY = 'tuvens_auth_token';
  private static readonly REFRESH_TOKEN_KEY = 'tuvens_refresh_token';

  static setTokens(accessToken: string, refreshToken: string) {
    // Use httpOnly cookies in production
    if (process.env.NODE_ENV === 'production') {
      // Set via API call to set httpOnly cookies
      AuthService.setSecureCookies(accessToken, refreshToken);
    } else {
      localStorage.setItem(this.TOKEN_KEY, accessToken);
      localStorage.setItem(this.REFRESH_TOKEN_KEY, refreshToken);
    }
  }

  static getAccessToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  static clearTokens() {
    localStorage.removeItem(this.TOKEN_KEY);
    localStorage.removeItem(this.REFRESH_TOKEN_KEY);
  }

  static isTokenExpired(token: string): boolean {
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      return payload.exp * 1000 < Date.now();
    } catch {
      return true;
    }
  }
}
```

#### Input Validation
```typescript
// Client-side validation with server-side verification
import { z } from 'zod';

const eventSchema = z.object({
  title: z.string().min(1, 'Title is required').max(100, 'Title too long'),
  description: z.string().min(10, 'Description must be at least 10 characters'),
  date: z.string().datetime('Invalid date format'),
  location: z.string().min(1, 'Location is required'),
  ticketPrice: z.number().min(0, 'Price cannot be negative'),
});

type EventFormData = z.infer<typeof eventSchema>;

const EventForm = ({ onSubmit }: { onSubmit: (data: EventFormData) => void }) => {
  const { register, handleSubmit, formState: { errors } } = useForm<EventFormData>({
    resolver: zodResolver(eventSchema),
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('title')}
        placeholder="Event Title"
        aria-invalid={!!errors.title}
        aria-describedby={errors.title ? 'title-error' : undefined}
      />
      {errors.title && (
        <p id="title-error" role="alert" className="text-red-500">
          {errors.title.message}
        </p>
      )}
      {/* Other form fields */}
    </form>
  );
};
```

### XSS Protection

#### Content Sanitization
```typescript
// Sanitize user-generated content
import DOMPurify from 'dompurify';

const SafeHTML = ({ content }: { content: string }) => {
  const sanitizedHTML = DOMPurify.sanitize(content, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'ul', 'ol', 'li'],
    ALLOWED_ATTR: [],
  });

  return <div dangerouslySetInnerHTML={{ __html: sanitizedHTML }} />;
};

// URL validation
const isValidURL = (url: string): boolean => {
  try {
    const parsedURL = new URL(url);
    return ['http:', 'https:'].includes(parsedURL.protocol);
  } catch {
    return false;
  }
};
```