const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config(); // Cargar las variables de entorno desde .env

const app = express();

// Middleware para permitir CORS
app.use(cors());

// Middleware para parsear JSON
app.use(express.json());

// Cadena de conexión de MongoDB Atlas desde el archivo .env
const mongoUri = process.env.MONGO_URI;

// Verifica si mongoUri está definido
if (!mongoUri) {
  console.error('La cadena de conexión de MongoDB no está definida en el archivo .env');
  process.exit(1);
}

// Conectar a MongoDB
mongoose.connect(mongoUri, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('Conectado a MongoDB'))
  .catch(err => console.error('Error al conectar a MongoDB:', err));

// Definir el esquema y el modelo para los nombres
const nombreSchema = new mongoose.Schema({
  name: { type: String, required: true }
});

const Nombre = mongoose.model('Nombre', nombreSchema);

// Definir el esquema y el modelo para los productos
const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, required: true },
  price: { type: Number, required: true },
  stock: { type: Number, required: true }
});

const Product = mongoose.model('Product', productSchema);

// ========================= Rutas para Nombres ==============================
// Ruta GET para obtener todos los nombres
app.get('/api/nombres', async (req, res) => {
  try {
    const nombres = await Nombre.find();
    res.json({
      message: 'Lista de nombres obtenida con éxito',
      nombres: nombres.map(n => n.name)
    });
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener nombres' });
  }
});

// Ruta POST para agregar un nombre
app.post('/api/nombres', async (req, res) => {
  const { name } = req.body;
  try {
    const nuevoNombre = new Nombre({ name });
    await nuevoNombre.save();
    res.json({
      message: `Nombre ${name} recibido con éxito`,
      nombre: name
    });
  } catch (err) {
    res.status(500).json({ error: 'Error al guardar el nombre' });
  }
});

// ========================= Rutas para Productos ==============================
// Ruta GET para obtener todos los productos
app.get('/api/productos', async (req, res) => {
  try {
    const productos = await Product.find();
    res.json({
      message: 'Lista de productos obtenida con éxito',
      productos
    });
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener productos' });
  }
});

// Ruta POST para agregar un producto
app.post('/api/productos', async (req, res) => {
  const { name, description, price, stock } = req.body;
  try {
    const nuevoProducto = new Product({ name, description, price, stock });
    await nuevoProducto.save();
    res.json({
      message: `Producto ${name} registrado con éxito`,
      producto: nuevoProducto
    });
  } catch (err) {
    res.status(500).json({ error: 'Error al guardar el producto' });
  }
});

// Puerto dinámico proporcionado por el entorno o puerto 3000 si está corriendo localmente
const PORT = process.env.PORT || 3000;

// Iniciar el servidor
app.listen(PORT, () => {
  console.log(`Servidor corriendo en el puerto ${PORT}`);
});
