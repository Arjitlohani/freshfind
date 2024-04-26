const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');
const twilio = require('twilio');
const multer = require('multer');
const path = require('path');

const app = express();
const port = 3000;

app.use(bodyParser.json());



// Temporary storage for OTP
const otpStorage = {};


async function sendOTP(phoneNumber) {
    // Validate phone number format
    const phoneNumberPattern = /^\d{10}$/;
    if (!phoneNumberPattern.test(phoneNumber)) {
        console.error("Invalid phone number format:", phoneNumber);
        throw new Error("Invalid phone number format");
    }

    // Concatenate with country code +977
    const formattedPhoneNumber = `+977${phoneNumber}`;

    const otp = Math.floor(100000 + Math.random() * 900000);
    otpStorage[formattedPhoneNumber] = otp.toString();  // Store OTP in the temporary storage
    
    // Debugging: Print the formatted phone number
    console.log("Sending OTP to:", formattedPhoneNumber);

    try {
        await twilioClient.messages.create({
            body: `Your OTP for registration is ${otp}.`,
            from: TWILIO_PHONE_NUMBER,
            to: formattedPhoneNumber,
        });
        return otp;  // Return the generated OTP
    } catch (error) {
        console.error("Error sending OTP:", error);
        throw error;
    }
}


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

app.post('/login', (req, res) => {
    const { emailOrUsername, password } = req.body;

    if (!emailOrUsername || !password) {
        return res.status(400).json({ message: 'Email/Username and password are required' });
    }

    const query = `
    SELECT user.*, role.role_id as role
    FROM user 
    JOIN role ON user.role = role.role_id 
    WHERE (email = ? OR user_name = ?) AND password = ?
`;

    connection.query(query, [emailOrUsername, emailOrUsername, password], (error, results) => {
        if (error) {
            console.error('Error executing query:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        if (results.length === 0) {
            return res.status(401).json({ message: 'Invalid email/username or password' });
        }

        return res.status(200).json({ message: 'Login successful', role: results[0].role, user_id: results[0].user_id });
    });
});

app.post('/sendOTP', async (req, res) => {
    let { phone_number } = req.body;
    try {
        const otp = await sendOTP(phone_number);  // Send OTP and get the generated OTP
        res.status(200).json({ message: 'OTP sent successfully', otp: otp });
    } catch (error) {
        console.error('Error sending OTP:', error);
        res.status(500).json({ message: 'Error sending OTP' });
    }
});

app.post('/signup', (req, res) => {
    const { username, email, password, phone_number, address, otp } = req.body;

    if (!username || !email || !password || !phone_number || !address || !otp) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    // Concatenate with country code +977
    const formattedPhoneNumber = `+977${phone_number}`;

    connection.query('SELECT * FROM user WHERE user_name = ?', [username], (error, results) => {
        if (error) {
            console.error('Error checking existing user:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        if (results.length > 0) {
            return res.status(409).json({ message: 'Username is already registered' });
        }

        // Validate OTP from temporary storage
        if (otpStorage[formattedPhoneNumber] !== otp) {
            console.error('Invalid OTP:', otp, 'Expected:', otpStorage[formattedPhoneNumber]);
            return res.status(401).json({ message: 'Invalid OTP' });
        }

        const query = 'INSERT INTO user (user_name, email, password, phone_number, address) VALUES (?, ?, ?, ?, ?)';
        connection.query(query, [username, email, password, phone_number, address], (error) => {
            if (error) {
                console.error('Error executing signup query:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }

            // Delete OTP from temporary storage after successful signup
            delete otpStorage[formattedPhoneNumber];

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
        return res.status(200).json(results[0]);

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

const baseURL = 'http://192.168.1.6:3000';
app.get('/products/vendor/:vendorId', (req, res) => {
    const vendorId = req.params.vendorId;
    const query = `
        SELECT p.*, CONCAT('${baseURL}/', i.image_url) AS image_url, p.quantity
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
  
app.post('/orders', (req, res) => {
    const { customer_id, total_price, order_status, order_items, delivery_time, delivery_address, vendor_id } = req.body;

    // Check if customer exists
    const checkCustomerQuery = 'SELECT * FROM user WHERE user_id = ?';
    connection.query(checkCustomerQuery, [customer_id], (error, customerRows) => {
        if (error) {
            return res.status(500).json({ message: 'Internal server error' });
        }

        if (customerRows.length === 0) {
            return res.status(404).json({ message: 'Customer not found' });
        }

        // Start transaction
        connection.beginTransaction((error) => {
            if (error) {
                return res.status(500).json({ message: 'Internal server error' });
            }

            // Insert order details
            const orderQuery = 'INSERT INTO orders (customer_id, total_price, order_status, delivery_time, delivery_address, vendor_id) VALUES (?, ?, ?, ?, ?, ?)';
            connection.query(orderQuery, [customer_id, total_price, order_status, delivery_time, delivery_address, vendor_id], (error, orderResults) => {
                if (error) {
                    connection.rollback(() => {
                        return res.status(500).json({ message: 'Internal server error' });
                    });
                }

                const orderId = orderResults.insertId;

                // Insert order items
                const orderItemsQuery = 'INSERT INTO order_items (order_id, product_id, quantity, rate) VALUES ?';
                const orderItemsData = order_items.map(item => [orderId, item.product_id, item.quantity, item.rate]);

                connection.query(orderItemsQuery, [orderItemsData], (error) => {
                    if (error) {
                        connection.rollback(() => {
                            return res.status(500).json({ message: 'Internal server error' });
                        });
                    }

                    // Update product quantity
                    for (const item of order_items) {
                        const updateQuantityQuery = 'UPDATE products SET quantity = quantity - ? WHERE product_id = ?';
                        connection.query(updateQuantityQuery, [item.quantity, item.product_id], (error) => {
                            if (error) {
                                connection.rollback(() => {
                                    return res.status(500).json({ message: 'Internal server error' });
                                });
                            }
                        });
                    }

                    // Commit transaction
                    connection.commit((error) => {
                        if (error) {
                            return res.status(500).json({ message: 'Internal server error' });
                        }

                        return res.status(200).json({ message: 'Order placed successfully', orderId });
                    });
                });
            });
        });
    });
});

//user id and role for order page 
app.get('/userDetails/:id', (req, res) => {
    const userId = req.params.id;

    const query = `
        SELECT user.*, role.role_id as role
        FROM user 
        JOIN role ON user.role = role.role_id 
        WHERE user_id = ?
    `;

    connection.query(query, [userId], (error, results) => {
        if (error) {
            console.error('Error fetching user details:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        return res.status(200).json(results[0]);
    });
});



// Fetch Orders for customer
app.get('/customer/orders', (req, res) => {
    const customerId = req.query.customerId;

    // Check if customer ID is provided
    if (!customerId) {
        return res.status(400).json({ message: 'Customer ID is required' });
    }
    const query = `
      SELECT * FROM orders
      WHERE customer_id = ?
    `;
  
    connection.query(query, [customerId], (error, results) => { 

      if (error) {
        console.error('Error fetching orders:', error);
        return res.status(500).json({ error: 'Failed to fetch orders' });
      }
  
      res.json({ orders: results });
    });
});




// Fetch Orders for Vendor
app.get('/vendor/orders', (req, res) => {
    const vendorId = req.query.vendorId;
  
    const query = `
      SELECT * FROM orders
      WHERE vendor_id = ?
    `;
  
    connection.query(query, [vendorId], (error, results) => {
      if (error) {
        console.error('Error fetching orders:', error);
        return res.status(500).json({ error: 'Failed to fetch orders' });
      }
  
      res.json({ orders: results });
    });
});
  
// Fetch Order Details for Order
app.get('/vendor/orders/:orderId/details', (req, res) => {
    const orderId = req.params.orderId;
  
    const query = `
        SELECT p.name, oi.quantity, oi.rate, o.order_date, o.delivery_time, o.delivery_address
        FROM order_items oi
        JOIN products p ON oi.product_id = p.product_id
        JOIN orders o ON oi.order_id = o.order_id
        WHERE oi.order_id = ?
        `;

  
    connection.query(query, [orderId], (error, results) => {
      if (error) {
        console.error('Error fetching order details:', error);
        return res.status(500).json({ error: 'Failed to fetch order details' });
      }
  
      res.json({ order_items: results });
    });
});



// Endpoint to update order status by order ID
app.put('/orders/:id/status', (req, res) => {
    const orderId = req.params.id;
    const { order_status } = req.body;

    // Check if order status is provided
    if (!order_status) {
        return res.status(400).json({ message: 'Order status is required' });
    }

    // Query to update order status in the database
    const query = 'UPDATE orders SET order_status = ? WHERE order_id = ?';
    connection.query(query, [order_status, orderId], (error, results) => {
        if (error) {
            console.error('Error updating order status:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // Check if the order was updated successfully
        if (results.affectedRows === 0) {
            return res.status(404).json({ message: 'Order not found' });
        }

        // Order status updated successfully
        return res.status(200).json({ message: 'Order status updated successfully' });
    });
});


// Fetch Placed Orders for driver dashboard
app.get('/driver/orders/placed', (req, res) => {
    const query = `
      SELECT o.*, oi.product_id, oi.quantity, oi.rate, p.name as product_name
      FROM orders o
      JOIN order_items oi ON o.order_id = oi.order_id
      JOIN products p ON oi.product_id = p.product_id
      WHERE o.order_status = 'Placed'
    `;

    connection.query(query, (error, results) => {
        if (error) {
            console.error('Error fetching placed orders:', error);
            return res.status(500).json({ error: 'Failed to fetch placed orders' });
        }

        res.json({ orders: results });
    });
});

// Endpoint to fetch accepted orders for driver
app.get('/driver/orders/accepted', (req, res) => {
    const query = `
        SELECT o.*, oi.product_id, oi.quantity, oi.rate, p.name as product_name
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
        WHERE o.order_status = 'Accept'
    `;

    connection.query(query, (error, results) => {
        if (error) {
            console.error('Error fetching accepted orders:', error);
            return res.status(500).json({ error: 'Failed to fetch accepted orders' });
        }

        res.json({ orders: results });
    });
});


app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Something broke!');
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});