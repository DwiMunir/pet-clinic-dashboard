#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Next.js Design Pattern Setup                ${NC}"
echo -e "${BLUE}   (For existing Next.js 16 project)           ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if we're in a Next.js project
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: package.json not found!${NC}"
    echo -e "${RED}Please run this script in your Next.js project root directory.${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Detected existing Next.js project"
echo ""

# Create main folder structure
echo -e "${YELLOW}Creating design pattern folder structure...${NC}"

# Root folders
mkdir -p src/{app,components,page,hooks,infra,types,utils,constant,styles}
mkdir -p public/images
mkdir -p messages

# App Router structure
mkdir -p src/app/\[locale\]/{auth,dashboard}
mkdir -p src/app/api

# Components structure (Atomic Design)
mkdir -p src/components/{atoms,molecules,organisms}
mkdir -p src/components/atoms/{my-button,my-text-input,my-checkbox,my-icon}
mkdir -p src/components/molecules/{my-modal,my-table,my-pagination}
mkdir -p src/components/organisms/{my-header,my-sidebar}

# Page structure
mkdir -p src/page/{auth,dashboard}/components
mkdir -p src/page/{auth,dashboard}/hooks

# Infrastructure structure
mkdir -p src/infra/{axios,queries,services,storage,config}
mkdir -p src/infra/axios
mkdir -p src/infra/queries/hooks
mkdir -p src/infra/services/api
mkdir -p src/infra/storage/{zustand/slices,context}

# Types structure
mkdir -p src/types

echo -e "${GREEN}✓${NC} Folder structure created"

# Install required dependencies (if not already installed)
echo -e "${YELLOW}Checking required dependencies...${NC}"

# Check if package.json has required dependencies
REQUIRED_DEPS="zustand @tanstack/react-query axios react-hook-form @hookform/resolvers zod next-intl dayjs react-hot-toast daisyui"

echo -e "${BLUE}The following dependencies are recommended for the design pattern:${NC}"
echo -e "  - zustand (State management)"
echo -e "  - @tanstack/react-query (Data fetching)"
echo -e "  - axios (HTTP client)"
echo -e "  - react-hook-form & @hookform/resolvers & zod (Form handling)"
echo -e "  - next-intl (Internationalization)"
echo -e "  - dayjs (Date utility)"
echo -e "  - react-hot-toast (Toast notifications)"
echo -e "  - daisyui (Tailwind CSS components)"
echo ""
echo -e "${YELLOW}Install them manually with:${NC}"
echo -e "  npm install zustand @tanstack/react-query axios react-hook-form @hookform/resolvers zod next-intl dayjs react-hot-toast daisyui"
echo ""

# Update tsconfig.json paths
echo -e "${YELLOW}Updating tsconfig.json with design pattern path aliases...${NC}"

if [ -f "tsconfig.json" ]; then
    # Create backup
    cp tsconfig.json tsconfig.json.backup
    
    # Check if paths already exist
    if grep -q '"@components"' tsconfig.json; then
        echo -e "${YELLOW}⚠${NC}  Path aliases already exist in tsconfig.json"
    else
        echo -e "${BLUE}Please manually add these path aliases to your tsconfig.json:${NC}"
        echo ""
        cat << 'EOL'
    "paths": {
      "@/*": ["./src/*"],
      "@components": ["src/components/"],
      "@components/*": ["src/components/*"],
      "@hooks": ["src/hooks/"],
      "@hooks/*": ["src/hooks/*"],
      "@infra": ["src/infra/"],
      "@infra/*": ["src/infra/*"],
      "@pages": ["src/page"],
      "@pages/*": ["src/page/*"],
      "@types-app": ["src/types"],
      "@types-app/*": ["src/types/*"],
      "@utils": ["src/utils"],
      "@utils/*": ["src/utils/*"],
      "@constant": ["src/constant"],
      "@constant/*": ["src/constant/*"]
    }
EOL
        echo ""
    fi
else
    echo -e "${RED}⚠${NC}  tsconfig.json not found"
fi

echo -e "${GREEN}✓${NC} Configuration update completed"

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cat > .env << 'EOL'
NEXT_PUBLIC_API_BASE_URL=http://localhost:3001/api
NEXT_PUBLIC_ENCRYPTION_KEY=your-encryption-key-here
EOL
    echo -e "${GREEN}✓${NC} .env file created"
else
    echo -e "${YELLOW}⚠${NC}  .env file already exists (skipped)"
fi

# Create .env.example
echo -e "${YELLOW}Creating .env.example...${NC}"
cat > .env.example << 'EOL'
NEXT_PUBLIC_API_BASE_URL=http://localhost:3001/api
NEXT_PUBLIC_ENCRYPTION_KEY=your-encryption-key-here
EOL
echo -e "${GREEN}✓${NC} .env.example created"

# Create or update README section
echo -e "${YELLOW}Creating DESIGN_PATTERN.md documentation...${NC}"
cat > DESIGN_PATTERN.md << 'EOL'
# Design Pattern Documentation

## Project Structure

This project follows a layered architecture with Atomic Design pattern for components.

### Folder Structure

```
src/
├── app/                    # Next.js App Router
│   └── [locale]/          # Internationalization
│       ├── auth/          # Authentication pages
│       └── dashboard/     # Dashboard pages
├── components/            # UI Components (Atomic Design)
│   ├── atoms/            # Basic building blocks
│   ├── molecules/        # Simple combinations
│   └── organisms/        # Complex components
├── page/                 # Page-specific logic
│   ├── auth/
│   │   ├── components/  # Page-specific components
│   │   └── hooks/       # Page-specific hooks
│   └── dashboard/
├── hooks/                # Shared custom hooks
├── infra/                # Infrastructure layer
│   ├── axios/           # HTTP client configuration
│   ├── queries/         # React Query hooks
│   ├── services/        # API services
│   ├── storage/         # State management
│   │   ├── zustand/    # Zustand stores
│   │   └── context/    # React Context
│   └── config/          # Configuration files
├── types/                # TypeScript types
├── utils/                # Utility functions
├── constant/             # Constants
└── styles/               # Global styles
```

## Design Patterns

### 1. Atomic Design (Components)
- **Atoms**: Basic UI elements (buttons, inputs, icons)
- **Molecules**: Simple combinations of atoms (modals, tables)
- **Organisms**: Complex UI sections (headers, sidebars)

### 2. Layered Architecture
- **Presentation Layer**: Components & Pages
- **Business Logic Layer**: Hooks & Services
- **Data Layer**: API calls & State management

### 3. Custom Hooks Pattern
- Separate business logic from UI components
- Reusable logic across the application

### 4. Service Layer Pattern
- Centralized API communication
- Consistent error handling

## Best Practices

1. **Component Organization**
   - Each component in its own folder
   - Include index.ts, Component.tsx, types.ts
   - Co-locate related files

2. **State Management**
   - Use Zustand for global state
   - React Query for server state
   - Local state with useState/useReducer

3. **Type Safety**
   - Define interfaces in types.ts
   - Use strict TypeScript mode
   - Avoid 'any' type

4. **Code Reusability**
   - Create custom hooks for shared logic
   - Use composition over inheritance
   - Follow DRY principle

## Getting Started

1. Install recommended dependencies
2. Update tsconfig.json with path aliases
3. Follow the folder structure
4. Start building your components!
EOL
echo -e "${GREEN}✓${NC} Documentation created"

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   Setup Complete! 🎉                          ${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${BLUE}Design pattern folder structure has been created!${NC}"
echo ""
echo -e "Next steps:"
echo -e "  ${BLUE}1.${NC} Review DESIGN_PATTERN.md for documentation"
echo -e "  ${BLUE}2.${NC} Update tsconfig.json with the path aliases (shown above)"
echo -e "  ${BLUE}3.${NC} Install recommended dependencies"
echo -e "  ${BLUE}4.${NC} Configure .env file"
echo -e "  ${BLUE}5.${NC} Start building with the design pattern!"
echo ""
echo -e "${YELLOW}Tip:${NC} A backup of your tsconfig.json has been created as tsconfig.json.backup"
echo ""
