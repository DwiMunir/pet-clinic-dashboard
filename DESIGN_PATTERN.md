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
