const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');
const multer = require('multer');
const cors = require('cors');
const path = require('path'); 
const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

// Specify the full path to the uploads directory
const uploadsPath = path.join(__dirname, 'uploads');

// Serve static files from the uploads directory
app.use('/uploads', express.static(uploadsPath));
// Define storage for uploaded files

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/') // Use the 'uploads' folder for storing uploaded files
    },
    filename: function (req, file, cb) {
        // Ensure unique file names to prevent overwriting existing files
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + '-' + file.originalname);
    },
});
  
  // Initialize multer with the storage configuration
  const upload = multer({ storage: storage });


const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'freshfind'
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
        return res.status(200).json({ message: 'Login successful', role: results[0].role, user_id: results[0].user_id  });
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
            console.error('Error executing SELECT query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        if (results.length > 0) {
            return res.status(409).json({ message: 'Email is already registered' });
        }

        const query = 'INSERT INTO user (user_name, email, password, phone_number, address, role) VALUES (?, ?, ?, ?, ?, ?)';
        connection.query(query, [username, email, password, phone_number, address, role], (error) => {
            if (error) {
                console.error('Error executing INSERT query:', error);
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
            return res.status(200).json({ exists: false });
        } else {
            return res.status(200).json({ exists: true });
        }
    });
}); 

app.put('/users/:id', (req, res) => {
    const userId = req.params.id;
    const { username, email, password, phone_number, address, role } = req.body;

    // Check if all required fields are provided
    if (!username || !email || !password || !phone_number || !address || !role) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    // Check if the role is valid (you can add additional checks here if needed)
    if (![1, 2, 3, 4].includes(role)) {
        return res.status(400).json({ message: 'Invalid role' });
    }

    // Query to update user details in the database
    const query = 'UPDATE user SET user_name = ?, email = ?, password = ?, phone_number = ?, address = ?, role = ? WHERE user_id = ?';
    connection.query(query, [username, email, password, phone_number, address, role, userId], (error, results) => {
        if (error) {
            console.error('Error updating user:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // Check if the user was updated successfully
        if (results.affectedRows === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        // User updated successfully
        return res.status(200).json({ message: 'User updated successfully' });
    });
});

app.delete('/users/:id', (req, res) => {
    const userId = req.params.id;

    // Query to delete user by ID
    const query = 'DELETE FROM user WHERE user_id = ?'; // primary key column is 'user_id'
    connection.query(query, [userId], (error, results) => {
        if (error) {
            console.error('Error executing query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // Check if the user was deleted successfully
        if (results.affectedRows === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        // User deleted successfully
        return res.status(200).json({ message: 'User deleted successfully' });
    });
});


// Endpoint to get all products with image URLs
app.get('/products', (req, res) => {
    const query = `
        SELECT p.*, i.image_url
        FROM Products p
        LEFT JOIN images i ON p.product_id = i.product_id
    `;
    connection.query(query, (error, results) => {
        if (error) {
            console.error('Error executing query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        return res.status(200).json({ products: results });
    });
});

// Endpoint to add a new product
app.post('/products', (req, res) => {
    const { name, description, rate, quantity, vendor_id, category_id } = req.body;

    // Check if all required fields are provided
    if (!name || !description || !rate || !quantity || !vendor_id || !category_id) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    // Insert the new product into the database
    const query = 'INSERT INTO Products (name, description, rate, quantity, vendor_id, category_id) VALUES (?, ?, ?, ?, ?, ?)';
    
    connection.query(query, [name, description, rate, quantity, vendor_id, category_id], (error, results) => {
        if (error) {
            console.error('Error adding product:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }
        
        // Product added successfully
        res.status(201).json({ message: 'Product added successfully', productId: results.insertId });
    });
});

// Endpoint to handle image uploads
app.post('/upload', upload.single('image'), (req, res) => {
    const productId = req.body.productId;
    const imageUrl = 'uploads/' + req.file.filename; // Construct the image URL

    // Insert the image URL and product ID into the images table
    const query = 'INSERT INTO images (product_id, image_url) VALUES (?, ?)';
    connection.query(query, [productId, imageUrl], (error, results) => {
        if (error) {
            console.error('Error inserting image record:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }
        return res.status(200).json({ message: 'Image uploaded successfully' });
    });
});


// Endpoint to search for a product by ID
app.get('/products/:id', (req, res) => {
    const productId = req.params.id;

    // Query to fetch product by ID along with image URL
    const query = `
        SELECT p.*, i.image_url
        FROM Products p
        LEFT JOIN images i ON p.product_id = i.product_id
        WHERE p.product_id = ?
    `;
    connection.query(query, [productId], (error, results) => {
        if (error) {
            console.error('Error searching for product:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // If no product found, return 404
        if (results.length === 0) {
            return res.status(404).json({ message: 'Product not found.' });
        }

        // Return the product along with the image URL
        return res.status(200).json(results[0]);
    });
});

// Endpoint to update a product by ID
app.put('/products/:id', (req, res) => {
    const productId = req.params.id;

    // Extract updated product details from the request body
    const { name, description, rate, quantity, category_id } = req.body;

    // Query to update product details in the database
    const query = 'UPDATE Products SET name = ?, description = ?, rate = ?, quantity = ?,category_id = ? WHERE product_id = ?';
    connection.query(query, [name, description, rate, quantity, category_id, productId], (error, results) => {
        if (error) {
            console.error('Error updating product:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // Check if the product was updated successfully
        if (results.affectedRows === 0) {
            return res.status(404).json({ message: 'Product not found' });
        }

        // Product updated successfully
        return res.status(200).json({ message: 'Product updated successfully' });
    });
});

// Endpoint to delete a product by ID
app.delete('/products/:id', (req, res) => {
    const productId = req.params.id;

    // Query to delete associated images from the Images table
    const deleteImagesQuery = 'DELETE FROM Images WHERE product_id = ?';
    connection.query(deleteImagesQuery, [productId], (error, deleteImagesResults) => {
        if (error) {
            console.error('Error deleting associated images:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // Query to delete product details from the Products table
        const deleteProductQuery = 'DELETE FROM Products WHERE product_id = ?';
        connection.query(deleteProductQuery, [productId], (error, deleteProductResults) => {
            if (error) {
                console.error('Error deleting product:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }

            if (deleteProductResults.affectedRows === 0) {
                return res.status(404).json({ message: 'Product not found' });
            }

            return res.status(200).json({ message: 'Product deleted successfully' });
        });
    });
});

// Endpoint to fetch all vendors
app.get('/vendors', (req, res) => {
    const query = 'SELECT * FROM user WHERE role = 2 ORDER BY user_name ASC';
    connection.query(query, (error, results) => {
        if (error) {
            console.error('Error fetching vendors:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }
        return res.status(200).json({ vendors: results });
    });
});

const baseURL = 'http://192.168.1.113:3000';
app.get('/products/vendor/:vendorId', (req, res) => {
    const vendorId = req.params.vendorId;
    const query = `
        SELECT p.*, CONCAT('${baseURL}/', i.image_url) AS image_url 
        FROM Products p
        LEFT JOIN images i ON p.product_id = i.product_id
        WHERE p.vendor_id = ?;
    `;
    connection.query(query, [vendorId], (error, results) => {
        if (error) {
            console.error('Error fetching products by vendor:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }
        return res.status(200).json(results);
    });
});

// Fetch User Data Endpoint
app.get('/user/profile', (req, res) => {
    // Assuming you have a 'users' table with columns: id, name, email
    const query = 'SELECT name, email FROM users WHERE id = ?';
    connection.query(query, [req.user.id], (error, results) => {
      if (error) {
        console.error('Error fetching user data:', error);
        return res.status(500).json({ message: 'Internal server error' });
      }
      if (results.length === 0) {
        return res.status(404).json({ message: 'User not found' });
      }
      const userData = results[0];
      return res.status(200).json(userData);
    });
  });
  
// Endpoint to update user profile
app.put('/users/update/:id', (req, res) => {
    const userId = req.params.id;
    const { user_name, email, phone_number, address } = req.body;

    // Check if all required fields are provided
    if (!user_name || !email || !phone_number || !address) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    // Query to update user details in the database
    const query = 'UPDATE user SET user_name = ?, email = ?, phone_number = ?, address = ? WHERE user_id = ?';
    connection.query(query, [user_name, email, phone_number, address, userId], (error, results) => {
        if (error) {
            console.error('Error updating user:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // Check if the user was updated successfully
        if (results.affectedRows === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        // User updated successfully
        return res.status(200).json({ message: 'User updated successfully' });
    });
});
  
// Endpoint to handle placing an order
app.post('/orders', (req, res) => {
    const { customer_id, total_price, order_status, order_items } = req.body;

    // Check if the customer exists
    const checkCustomerQuery = 'SELECT * FROM user WHERE user_id = ?';
    connection.query(checkCustomerQuery, [customer_id], (error, results) => {
        if (error) {
            console.error('Error checking customer:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // If the customer doesn't exist, return an error
        if (results.length === 0) {
            return res.status(404).json({ message: 'Customer not found' });
            console.log('Attempting to insert order for customer ID:', customer_id);

        }

        // Insert the order details into the orders table
        const orderQuery = 'INSERT INTO orders (customer_id, total_price, order_status) VALUES (?, ?, ?)';
        connection.query(orderQuery, [customer_id, total_price, order_status], (error, orderResults) => {
            if (error) {
                console.error('Error adding order:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }

            const orderId = orderResults.insertId;

            // Insert the order items into the order_items table
            const orderItemsQuery = 'INSERT INTO order_items (order_id, product_id, quantity, rate) VALUES ?';
            
            // Prepare the order items data for insertion
            const orderItemsData = order_items.map(item => [orderId, item.product_id, item.quantity, item.rate]);

            connection.query(orderItemsQuery, [orderItemsData], (error) => {
                if (error) {
                    console.error('Error adding order items:', error);
                    return res.status(500).json({ message: 'Internal server error' });
                }

                return res.status(200).json({ message: 'Order placed successfully', orderId });
            });
        });
    });
});

//  // Endpoint to fetch all customer
// app.get('/customer', (req, res) => {
//     const query = 'SELECT * FROM user WHERE role = 3 ORDER BY user_name ASC';
//     connection.query(query, (error, results) => {
//         if (error) {
//             console.error('Error fetching vendors:', error);
//             return res.status(500).json({ message: 'Internal server error' });
//         }
//         return res.status(200).json({ vendors: results });
//     });
// });

app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Something broke!');
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});