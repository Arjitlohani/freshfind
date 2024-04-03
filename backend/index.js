const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');
const cors = require('cors'); // Import the CORS middleware
const app = express();
const multer = require('multer'); // For handling file uploads
const fs = require('fs');

const port = 3000;

app.use(cors({
    origin: 'http://localhost:62053' 
  }));

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
    const query = 'SELECT * FROM user WHERE user_id = ?'; // primary key column is 'user_id'
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

app.get('/users', (req, res) => {
    const limit = req.query.limit ? parseInt(req.query.limit) : 5;
    const offset = req.query.offset ? parseInt(req.query.offset) : 0;

    const query = 'SELECT * FROM user LIMIT ? OFFSET ?';
    connection.query(query, [limit, offset], (error, results) => {
        if (error) {
            console.error('Error executing query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        return res.status(200).json({ users: results }); // Return users within a 'users' key
    });
});

// Endpoint to check if a username already exists
app.get('/users/search/name', (req, res) => {
    const username = req.query.name;

    // Query to check if the username exists
    const query = 'SELECT * FROM user WHERE user_name = ?';
    connection.query(query, [username], (error, results) => {
        if (error) {
            console.error('Error executing query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // If a user with the provided username exists, return appropriate response
        if (results.length > 0) {
            return res.status(200).json({ exists: true });
        } else {
            return res.status(200).json({ exists: false });
        }
    });
}); 




// Endpoint to get all products
app.get('/products', (req, res) => {
    const query = 'SELECT * FROM products';
    connection.query(query, (error, results) => {
        if (error) {
            console.error('Error executing query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        return res.status(200).json({ products: results });
    });
});

app.post('/products', (req, res) => {
    const { name, description, price, quantity, vendor_id, category_id, image_url } = req.body;

    // Check if all required fields are provided
    if (!name || !description || !price || !quantity || !vendor_id || !category_id || !image_url) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    // Insert the new product into the product table
    const productQuery = 'INSERT INTO Products (name, description, price, quantity, vendor_id, category_id) VALUES (?, ?, ?, ?, ?, ?)';
    connection.query(productQuery, [name, description, price, quantity, vendor_id, category_id], (productError, productResults) => {
        if (productError) {
            console.error('Error adding product:', productError);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // Insert the image URL into the image table
        const imageQuery = 'INSERT INTO Images (product_id, image_url) VALUES (?, ?)';
        const productId = productResults.insertId; // Assuming your product table has an auto-increment primary key
        connection.query(imageQuery, [productId, image_url], (imageError) => {
            if (imageError) {
                console.error('Error adding image:', imageError);
                return res.status(500).json({ message: 'Internal server error' });
            }

            return res.status(201).json({ message: 'Product added successfully' });
        });
    });
});

app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Something broke!');
});

// Middleware for file upload
const upload = multer({
    dest: 'uploads/' // Specify upload directory
});

// Process the uploaded file
app.post('/upload', upload.single('image'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'No file uploaded' });
    }
    
    // Access the uploaded file details
    const fileName = req.file.filename;
    const originalName = req.file.originalname;
    const mimeType = req.file.mimetype;
    const size = req.file.size;

    // Perform further processing here, such as saving the file to a directory or database
    // Example: Move the uploaded file to a specific directory
    const targetPath = `uploads/${fileName}`;
    fs.rename(req.file.path, targetPath, (err) => {
        if (err) {
            console.error('Error moving file:', err);
            return res.status(500).json({ message: 'Failed to process uploaded file' });
        }
        console.log('File processed successfully');
        res.status(200).json({ message: 'File uploaded and processed successfully' });
    });
});




// Endpoint to search for a product by ID
app.get('/products/:id', (req, res) => {
    const productId = req.params.id;

    // Query to fetch product by ID
    const query = 'SELECT * FROM Products WHERE product_id = ?';
    connection.query(query, [productId], (error, results) => {
        if (error) {
            console.error('Error searching for product:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // If no product found, return 404
        if (results.length === 0) {
            return res.status(404).json({ message: 'Product not found' });
        }

        // Return the product
        return res.status(200).json(results[0]);
    });
});
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});