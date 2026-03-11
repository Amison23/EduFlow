const request = require('supertest');
const express = require('express');

// We test the actual app initialization
const app = require('../src/index');

describe('Auth Endpoints (Minimal)', () => {
    it('should pass a smoke test', async () => {
        const res = await request(app).get('/health');
        expect(res.statusCode).toEqual(200);
        expect(res.body.status).toEqual('ok');
    });

    it('should return 400 for registration without body', async () => {
        const res = await request(app).post('/api/v1/auth/register').send({});
        expect(res.statusCode).toEqual(400);
    });
});
