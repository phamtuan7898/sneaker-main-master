const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const multer = require('multer');
const nodemailer = require('nodemailer');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 5002;
const upload = multer({ dest: 'uploads/' }); // Specify the uploads folder

app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

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
  userId: { 
    type: String,  // Changed from ObjectId to String for flexibility
    required: true 
  },
  productId: { 
    type: String, 
    required: true 
  },
  productName: { 
    type: String, 
    required: true 
  },
  price: { 
    type: String, 
    required: true 
  },
  quantity: { 
    type: Number, 
    required: true,
    default: 1,
    min: 1
  }
});
// Admin Schema
const adminSchema = new mongoose.Schema({
  adminname: { 
    type: String, 
    required: true,
    unique: true
  },
  adminpass: { 
    type: String, 
    required: true 
  }
});

const Admin = mongoose.model('Admin', adminSchema);
const CartItem = mongoose.model('CartItem', cartItemSchema);
const Product = mongoose.model('Product', productSchema);
const User = mongoose.model('User', userSchema);

// Admin login
app.post('/admin/login', async (req, res) => {
  const { adminname, adminpass } = req.body;
  
  try {
    const admin = await Admin.findOne({ adminname });
    
    if (!admin || admin.adminpass !== adminpass) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    res.json({ message: 'Login successful', adminId: admin._id });
  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// Get all admins
app.get('/admin', async (req, res) => {
  try {
    const admins = await Admin.find({}, { adminpass: 0 }); // Exclude password from response
    res.json(admins);
  } catch (error) {
    console.error('Error fetching admins:', error);
    res.status(500).json({ error: 'Error fetching admins' });
  }
});

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Thư mục lưu file
  },
  filename: (req, file, cb) => {
    // Tạo tên file duy nhất với timestamp
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});
// Cấu hình filter cho file
const fileFilter = (req, file, cb) => {
  // Chỉ chấp nhận file ảnh
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Not an image! Please upload only images.'), false);
  }
};
const uploads = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024 // Giới hạn 5MB
  }
});
// Thêm route xử lý upload nhiều ảnh
app.post('/uploads-images', upload.array('images', 5), async (req, res) => {
  try {
    const files = req.files;
    if (!files || files.length === 0) {
      return res.status(400).json({ 
        success: false,
        error: 'No files uploaded' 
      });
    }

    // Create array of image URLs
    const imageUrls = files.map(file => 
      `${req.protocol}://${req.get('host')}/uploads/${file.filename}`
    );
    
    res.status(200).json({
      success: true,
      imageUrls: imageUrls  // Changed from urls to imageUrls to match client expectation
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ 
      success: false,
      error: 'Error uploading files'
    });
  }
});

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
      let transporter = nodemailer.createTransport({
        service: 'Gmail',
        auth: {
          user: 'your-email@gmail.com',
          pass: '123456', // Replace with actual app password
        },
      });

      let mailOptions = {
        from: 'your-email@gmail.com',
        to: email,
        subject: 'Password Reset Request',
        text: 'Click the link to reset your password.',
        html: `<a href="http://your-app-link/reset-password?email=${email}">Reset Password</a>`
      };

      await transporter.sendMail(mailOptions);
      res.json({ message: 'Password reset link sent to your email.' });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error('Error processing forgot password:', error);
    res.status(500).json({ error: 'Error processing forgot password' });
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
// Add this route to your existing Express app
app.put('/User/:userId/change-password', async (req, res) => {
  const { userId } = req.params;
  const { oldPassword, newPassword } = req.body;

  try {
    // Find user by ID
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).send('User not found');
    }

    // Check if the old password matches
    if (user.password !== oldPassword) {
      return res.status(401).send('Old password is incorrect');
    }

    // Update the password
    user.password = newPassword;
    await user.save();

    return res.status(200).send('Password updated successfully');
  } catch (error) {
    console.error('Error changing password:', error);
    return res.status(500).send('Internal server error');
  }
});

// Delete account route
app.delete('/User/:id/delete-account', async (req, res) => {
  const { id } = req.params;
  const { password } = req.body;

  try {
    // Start a MongoDB session for transaction
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
      // 1. Find and verify user
      const user = await User.findById(id).session(session);
      if (!user || user.password !== password) {
        await session.abortTransaction();
        return res.status(401).json({ message: 'Invalid credentials' });
      }

      // 2. Delete all cart items for this user
      await CartItem.deleteMany({ userId: id }).session(session);

      // 3. Delete the user account
      await User.findByIdAndDelete(id).session(session);

      // 4. Commit the transaction
      await session.commitTransaction();
      return res.status(200).json({ message: 'Account deleted successfully' });

    } catch (error) {
      // If any error occurs, abort the transaction
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  } catch (error) {
    console.error('Error deleting account:', error);
    return res.status(500).json({ error: 'Error deleting account' });
  }
});


// Add new product
app.post('/products', async (req, res) => {
  const { productName, shoeType, image, price, rating, description, color, size } = req.body;
  try {
    const newProduct = new Product({ 
      productName, 
      shoeType, 
      image,
      price, 
      rating, 
      description, 
      color,
      size
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

// Trong file app.js
app.delete('/products/:id', async (req, res) => {
  const { id } = req.params;
  try {
    // Tìm và xoá sản phẩm
    await Product.findByIdAndDelete(id);
    res.status(200).json({ message: 'Sản phẩm đã được xoá thành công' });
  } catch (error) {
    console.error('Error deleting product:', error);
    res.status(500).json({ error: 'Error deleting product' });
  }
});
// Add this endpoint to your Express server code
app.put('/product/update/:id', async (req, res) => {
  const { id } = req.params;
  const { 
    productName, 
    shoeType, 
    image, 
    price, 
    rating, 
    description, 
    color, 
    size 
  } = req.body;

  try {
    const updatedProduct = await Product.findByIdAndUpdate(
      id,
      {
        productName,
        shoeType,
        image,
        price,
        rating,
        description,
        color,
        size
      },
      { new: true } // Return the updated document
    );

    if (!updatedProduct) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.status(200).json(updatedProduct);
  } catch (error) {
    console.error('Error updating product:', error);
    res.status(500).json({ error: 'Error updating product' });
  }
});
// Add new cart item
app.post('/cart', async (req, res) => {
  const { userId, productId, productName, price, quantity } = req.body;
  
  try {
    // Check if item already exists in user's cart
    const existingItem = await CartItem.findOne({ 
      userId: userId,
      productId: productId 
    });

    if (existingItem) {
      // Update quantity if item exists
      existingItem.quantity += quantity;
      await existingItem.save();
      res.status(200).json(existingItem);
    } else {
      // Create new cart item if doesn't exist
      const newCartItem = new CartItem({
        userId,
        productId,
        productName,
        price,
        quantity
      });
      await newCartItem.save();
      res.status(201).json(newCartItem);
    }
  } catch (error) {
    console.error('Error adding cart item:', error);
    res.status(500).json({ error: 'Error adding cart item' });
  }
});


// Get list of cart items
app.get('/cart/:userId', async (req, res) => {
  const { userId } = req.params;
  
  try {
    const cartItems = await CartItem.find({ userId: userId });
    res.json(cartItems);
  } catch (error) {
    console.error('Error fetching cart items:', error);
    res.status(500).json({ error: 'Error fetching cart items' });
  }
});

// Delete cart item
app.delete('/cart/:userId/:productId', async (req, res) => {
  const { userId, productId } = req.params;
  
  try {
    const result = await CartItem.findOneAndDelete({
      userId: userId,
      productId: productId
    });
    
    if (!result) {
      return res.status(404).json({ message: 'Cart item not found' });
    }
    
    res.json({ message: 'Cart item deleted successfully' });
  } catch (error) {
    console.error('Error deleting cart item:', error);
    res.status(500).json({ error: 'Error deleting cart item' });
  }
});

// Update cart item quantity
app.put('/cart/:userId/:productId', async (req, res) => {
  const { userId, productId } = req.params;
  const { quantity } = req.body;
  
  if (!quantity || quantity < 1) {
    return res.status(400).json({ message: 'Invalid quantity value' });
  }

  try {
    console.log(`Updating cart item: userId=${userId}, productId=${productId}, quantity=${quantity}`);
    
    const updatedItem = await CartItem.findOneAndUpdate(
      { 
        userId: userId.toString(),
        productId: productId.toString()
      },
      { quantity: quantity },
      { new: true }
    );
    
    if (!updatedItem) {
      console.log('Cart item not found with:', { userId, productId });
      return res.status(404).json({ 
        message: 'Cart item not found',
        details: { userId, productId }
      });
    }
    
    console.log('Successfully updated cart item:', updatedItem);
    res.json(updatedItem);
  } catch (error) {
    console.error('Error updating cart item:', error);
    res.status(500).json({ 
      error: 'Error updating cart item',
      details: error.message 
    });
  }
});


// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
