const request = require('supertest');
const app = require('../src/index');
const supabase = require('../src/config/supabase');

// Mock supabase
jest.mock('../src/config/supabase', () => ({
    from: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn().mockReturnThis(),
    order: jest.fn().mockReturnThis()
}));

describe('Logging Endpoints', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('should create a new log entry', async () => {
        supabase.insert.mockResolvedValue({ error: null });

        const logData = {
            level: 'error',
            message: 'Test error message',
            stackTrace: 'Test stack trace',
            source: 'test-suite',
            context: { test: true }
        };

        const res = await request(app)
            .post('/api/v1/logs')
            .send(logData);

        expect(res.statusCode).toEqual(201);
        expect(res.body.success).toBe(true);
        expect(supabase.from).toHaveBeenCalledWith('app_logs');
        expect(supabase.insert).toHaveBeenCalledWith([expect.objectContaining({
            level: 'error',
            message: 'Test error message',
            source: 'test-suite'
        })]);
    });

    it('should return 400 for missing required fields', async () => {
        const res = await request(app)
            .post('/api/v1/logs')
            .send({ level: 'info' });

        expect(res.statusCode).toEqual(400);
        expect(res.body.error).toBeDefined();
    });
});
