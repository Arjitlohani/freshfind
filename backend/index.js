const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');

const app = express();
const port = 3000;

app.use(bodyParser.json());

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'freshfinds'
});

// Endpoint to handle user login
app.post('/login', (req, res) => {
    const { email, password } = req.body;

    // Check if email and password are provided
    if (!email || !password) {
        return res.status(400).json({ message: 'Email and password are required' });
    }

    // Query to fetch user details along with role
    const query = `
        SELECT user.*, role.role_id as role
        FROM user 
        JOIN role ON user.role = role.role_id 
        WHERE email = ? AND password = ?
    `;
    connection.query(query, [email, password], (error, results, fields) => {
        if (error) {
            console.error('Error executing query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // If no user found, return authentication failed
        if (results.length === 0) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        // User found, return success along with role
        return res.status(200).json({ message: 'Login successful', role: results[0].role });
    });
});

// Endpoint to handle user signup
app.post('/signup', (req, res) => {
    const { username, email, password, phone_number, address } = req.body;

    // Check if all required fields are provided
    if (!username || !email || !password || !phone_number || !address) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    // Check if the email is already registered
    connection.query('SELECT * FROM user WHERE email = ?', [email], (error, results) => {
        if (error) {
            console.error('Error executing query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // If the email is already registered, return an error
        if (results.length > 0) {
            return res.status(409).json({ message: 'Email is already registered' });
        }

        // Insert the new user into the database
        const query = 'INSERT INTO user (user_name, email, password, phone_number, address) VALUES (?, ?, ?, ?, ?)';
        connection.query(query, [username, email, password, phone_number, address], (error) => {
            if (error) {
                console.error('Error executing query:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }

            // User successfully registered
            return res.status(201).json({ message: 'Signup successful' });
        });
    });
});

// Endpoint to get all users
app.get('/users', (req, res) => {
    // Query to fetch all users
    connection.query('SELECT * FROM user', (error, results) => {
        if (error) {
            console.error('Error executing query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // Return the list of users
        return res.status(200).json({ users: results });
    });
});

app.post('/users', (req, res) => {
    const { username, email, password, phone_number, address, role } = req.body;

    if (!username || !email || !password || !phone_number || !address || !role) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    if (![1, 2, 3, 4].includes(role)) {
        return res.status(400).json({ message: 'Invalid role' });
    }

    connection.query('SELECT * FROM user WHERE email = ?', [email], (error, results) => {
        if (error) {
            console.error('Error executing query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        if (results.length > 0) {
            return res.status(409).json({ message: 'Email is already registered' });
        }

        const query = 'INSERT INTO user (user_name, email, password, phone_number, address, role) VALUES (?, ?, ?, ?, ?, ?)';
        connection.query(query, [username, email, password, phone_number, address, role], (error) => {
            if (error) {
                console.error('Error executing query:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }

            return res.status(201).json({ message: 'User added successfully' });
        });
    });
});
app.get('/users/:id', (req, res) => {
    const userId = req.params.id;

    // Query to fetch user by ID
    const query = 'SELECT * FROM user WHERE user_id = ?'; // Assuming the primary key column is 'user_id'
    connection.query(query, [userId], (error, results) => {
        if (error) {
            console.error('Error executing query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // If no user found, return 404
        if (results.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Return the user
        return res.status(200).json(results);
    });
});


app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
