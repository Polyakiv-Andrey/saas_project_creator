#!/bin/bash

# Check if project name is provided
if [ -z "$1" ]; then
    echo "Please provide a project name"
    exit 1
fi

PROJECT_NAME=$1

# Create project directory
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

echo "Cloning frontend repository..."
git clone https://github.com/Polyakiv-Andrey/Saas-template-frontend.git frontend

echo "Cloning backend repository..."
git clone https://github.com/Polyakiv-Andrey/Saas-template-backend.git backend

echo "Creating PostgreSQL database..."
createdb -U postgres $PROJECT_NAME

echo "Setting up environment files..."

# Copy .env.sample to .env for frontend
cp frontend/.env.sample frontend/.env

# Copy .env.sample to .env for backend and add database settings
cp backend/.env.sample backend/.env
cat >> backend/.env << EOL

# Database settings
DB_ENGINE=django.db.backends.postgresql
DB_NAME=$PROJECT_NAME
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=localhost
DB_PORT=5432
EOL

echo "Installing frontend dependencies..."
cd frontend
npm install
cd ..

echo "Setting up Python virtual environment and installing backend dependencies..."
cd backend
python3.11 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo "Running database migrations..."
python manage.py makemigrations
python manage.py migrate

# Remove git dependencies
rm -rf .git
cd ../frontend
rm -rf .git
cd ..

echo "Project setup completed!"
echo ""
echo "IMPORTANT: Before starting the application, please configure your .env files:"
echo "1. Frontend: Edit $PROJECT_NAME/frontend/.env with your frontend settings"
echo "2. Backend: Edit $PROJECT_NAME/backend/.env with your backend settings"
echo ""
echo "To start the frontend, run: cd $PROJECT_NAME/frontend && npm run dev"
echo "To start the backend, run: cd $PROJECT_NAME/backend && source venv/bin/activate && python manage.py runserver" 