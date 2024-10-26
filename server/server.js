const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const multer = require('multer');

const app = express();
const PORT = process.env.PORT || 5002;
const upload = multer({ dest: 'uploads/' }); // Specify the uploads folder

app.use(cors());
app.use(bodyParser.json());

// Connect to MongoDB
mongoose.connect('mongodb+srv://haydygame:24HqXHnUuyIMvJJo@cluster0.bpo9e.mongodb.net/')
  .then(() => {
    console.log('Connected to MongoDB');
  }).catch((err) => {
    console.error('MongoDB connection error:', err);
});

// User Schema
const userSchema = new mongoose.Schema({
  username: { type: String, required: true },
  password: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  img: { type: String, default: '' }, // Default to empty string
  phone: { type: String, default: '' }, // Default to empty string
  address: { type: String, default: '' }, // Default to empty string
});


// Product Schema
const productSchema = new mongoose.Schema({
  productName: { type: String, required: true },
  shoeType: { type: String, required: true },
  image: [String], // Updated to array of strings for multiple images
  price: { type: String, required: true },
  rating: { type: Number, required: true },
  description: { type: String, required: true },
  color: [String], // Array of color strings
  size: [String],  // Array of size strings
});

// Cart Schema
const cartItemSchema = new mongoose.Schema({
  id: { type: String, required: true }, // Product ID
  productName: { type: String, required: true },
  price: { type: String, required: true },
  quantity: { type: Number, required: true, default: 1 },
});

const CartItem = mongoose.model('CartItem', cartItemSchema);
const Product = mongoose.model('Product', productSchema);
const User = mongoose.model('User', userSchema);

// Register User
app.post('/register', async (req, res) => {
  const { username, password, email } = req.body;
  const img = req.body.img || ''; // Default to empty string if not provided
  const phone = req.body.phone || ''; // Default to empty string if not provided
  const address = req.body.address || ''; // Default to empty string if not provided

  console.log("Received data:", req.body);
  try {
    const newUser = new User({ username, password, email, img, phone, address });
    await newUser.save();
    res.status(201).json(newUser);
  } catch (error) {
    console.error('Error registering user:', error);
    res.status(500).json({ error: 'Error registering user' });
  }
});


// Endpoint for uploading user profile images
app.post('/User/:id/upload-image', upload.single('image'), async (req, res) => {
  const { id } = req.params;
  try {
    const user = await User.findById(id);
    if (user) {
      user.img = req.file.path;
      await user.save();
      console.log("Updated user data:", user); // Log dữ liệu người dùng đã cập nhật
      res.status(200).json(user);
    } else {
      res.status(404).json({ message: 'User not found' });
    }
    
  } catch (error) {
    console.error('Error uploading image:', error);
    res.status(500).json({ error: 'Error uploading image' });
  }
});
// User Login
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const user = await User.findOne({
      $or: [{ username: username }, { email: username }], // Có thể đăng nhập bằng username hoặc email
    });

    console.log("User found:", user); // Kiểm tra người dùng tìm thấy
    if (!user || user.password !== password) {
      console.log("Invalid credentials");
      return res.status(400).json({ error: 'Invalid username or password' });
    }

    res.json(user); // Trả về thông tin người dùng khi đăng nhập thành công
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});


// Forgot Password (send reset email)
app.post('/forgot-password', async (req, res) => {
  const { email } = req.body;
  try {
    const user = await User.findOne({ email });
    if (user) {
      // Implement password reset logic (e.g., sending email)
      res.json({ message: 'Reset password link has been sent to your email.' });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error('Error handling forgot password:', error);
    res.status(500).json({ error: 'Error handling forgot password' });
  }
});
// Get user profile by ID
app.get('/User/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const user = await User.findById(id);
    if (user) {
      res.json(user); // Send user data
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ error: 'Error fetching user profile' });
  }
});
// Update user profile
app.put('/User/:id', async (req, res) => {
  const { id } = req.params;
  const { username, email, phone, address, img } = req.body;

  try {
    const updatedUser = await User.findByIdAndUpdate(
      id,
      { username, email, phone, address, img }, // Update user fields
      { new: true } // Return the updated user
    );

    if (updatedUser) {
      res.json(updatedUser);
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).json({ error: 'Error updating user profile' });
  }
});

// Add new product
app.post('/products', async (req, res) => {
  const { productName, shoeType, image, price, rating, description, color, size } = req.body;
  try {
    const newProduct = new Product({ 
      productName, 
      shoeType, 
      image,  // Now accepting array of image URLs
      price, 
      rating, 
      description, 
      color,  // Now accepting array of colors
      size    // Now accepting array of sizes
    });
    await newProduct.save();
    res.status(201).json(newProduct);
  } catch (error) {
    console.error('Error adding product:', error);
    res.status(500).json({ error: 'Error adding product' });
  }
});

// Get list of products
app.get('/products', async (req, res) => {
  try {
    const products = await Product.find();
    res.json(products);
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ error: 'Error fetching products' });
  }
});

// Add new cart item
app.post('/cart', async (req, res) => {
  const { id, productName, price, quantity } = req.body;
  try {
    const newCartItem = new CartItem({ id, productName, price, quantity });
    await newCartItem.save();
    res.status(201).json(newCartItem);
  } catch (error) {
    console.error('Error adding cart item:', error);
    res.status(500).json({ error: 'Error adding cart item' });
  }
});

// Get list of cart items
app.get('/cart', async (req, res) => {
  try {
    const cartItems = await CartItem.find();
    res.json(cartItems);
  } catch (error) {
    console.error('Error fetching cart items:', error);
    res.status(500).json({ error: 'Error fetching cart items' });
  }
});

// Delete cart item
app.delete('/cart/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await CartItem.findOneAndDelete({ id });
    if (result) {
      res.status(200).json({ message: 'Cart item deleted successfully' });
    } else {
      res.status(404).json({ message: 'Cart item not found' });
    }
  } catch (error) {
    console.error('Error deleting cart item:', error);
    res.status(500).json({ error: 'Error deleting cart item' });
  }
});

// Update cart item quantity
app.put('/cart/:id', async (req, res) => {
  const { id } = req.params;
  const { quantity } = req.body; // Expecting the new quantity in the request body
  try {
    const updatedCartItem = await CartItem.findOneAndUpdate(
      { id }, // Filter by id
      { quantity }, // Update quantity
      { new: true } // Return the updated document
    );
    if (updatedCartItem) {
      res.status(200).json(updatedCartItem);
    } else {
      res.status(404).json({ message: 'Cart item not found' });
    }
  } catch (error) {
    console.error('Error updating cart item quantity:', error);
    res.status(500).json({ error: 'Error updating cart item quantity' });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
