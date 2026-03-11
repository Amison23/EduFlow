import { createClient } from '@supabase/supabase-js';
import Cookies from 'js-cookie';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1';

/**
 * Fetch with Automatic Token Refresh & Error Handling
 */
async function apiFetch(endpoint: string, options: RequestInit = {}) {
    let token = Cookies.get('accessToken');

    const headers = {
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
        ...options.headers,
    };

    let response = await fetch(`${API_BASE_URL}${endpoint}`, {
        ...options,
        headers,
    });

    // Handle 401 Unauthorized (Potential token expiry)
    if (response.status === 401) {
        const refreshToken = Cookies.get('refreshToken');
        if (refreshToken) {
            const refreshRes = await fetch(`${API_BASE_URL}/auth/refresh-token`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ refreshToken }),
            });

            if (refreshRes.ok) {
                const refreshed = await refreshRes.json();
                const newAccessToken = refreshed.token || refreshed.accessToken;
                const newRefreshToken = refreshed.refreshToken;
                
                Cookies.set('accessToken', newAccessToken, { expires: 7 });
                Cookies.set('refreshToken', newRefreshToken, { expires: 30 });

                // Retry original request with new token
                return apiFetch(endpoint, {
                    ...options,
                    headers: {
                        ...options.headers,
                        'Authorization': `Bearer ${newAccessToken}`
                    }
                });
            }
        }
    }

    if (!response.ok) {
        const error = await response.json().catch(() => ({}));
        throw new Error(error.error || error.message || 'API Request failed');
    }

    return response.json();
}

export const api = {
    get: (endpoint: string) => apiFetch(endpoint, { method: 'GET' }),
    post: (endpoint: string, body: any) => apiFetch(endpoint, { 
        method: 'POST', 
        body: JSON.stringify(body) 
    }),
    getLearners: () => apiFetch('/auth/learners'),
    getLearnerDetails: (id: string) => apiFetch(`/auth/profile/${id}`),
    getAnalytics: () => apiFetch('/analytics/overview'),
    getDetailedAnalytics: () => apiFetch('/analytics/detailed'),
    getLessonPacks: () => apiFetch('/lessons/packs'),
    updateProfile: (data: any) => apiFetch('/auth/update-profile', { method: 'POST', body: JSON.stringify(data) }),
};
