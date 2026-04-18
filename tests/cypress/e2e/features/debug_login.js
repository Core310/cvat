// Copyright (C) CVAT.ai Corporation
//
// SPDX-License-Identifier: MIT

/// <reference types="cypress" />

describe('Auth page cases', () => {
    it('Admin can login on the server using valid credentials', () => {
        cy.visit('/auth/login');
        cy.get('#credential').should('be.visible').type('admin', { delay: 100 });
        // The password field appears after typing the credential
        cy.get('#password').should('be.visible').type('adminadmin', { delay: 100 });
        cy.get('button[type="submit"]').should('be.visible').click();
        
        cy.screenshot('after-submit');
        
        // Wait for redirect
        cy.url({ timeout: 30000 }).should('include', '/tasks');
        cy.get('.cvat-tasks-page', { timeout: 30000 }).should('be.visible');
    });
});
