#!/usr/bin/env bash

yarn init -y


echo "root = true
[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
" > .editorconfig


echo ".husky
.vscode
coverage
dist
documentation
node_modules
public
" > .eslintignore

echo '{
  "extends": "standard-with-typescript",
  "parserOptions": {
    "project": "./tsconfig.json"
  },
  "rules": {
    "@typescript-eslint/consistent-type-definitions": "off",
    "@typescript-eslint/no-namespace": "off",
    "@typescript-eslint/return-await": "off",
    "@typescript-eslint/no-non-null-assertion": "off"
  }
}
' > .eslintrc.json

echo "node_modules
dist
coverage
.env
" > .gitignore

echo '{
  "*.ts": [
    "npm run lint:fix",
    "npm run test:staged"
  ]
}
' > .lintstagedrc.json


echo "module.exports = {
  collectCoverageFrom: [
    '<rootDir>/src/**/*.ts',
    '!<rootDir>/src/main/**',
    '!<rootDir>/src/**/index.ts'
  ],
  coverageDirectory: 'coverage',
  coverageProvider: 'babel',
  moduleNameMapper: {
    '@/tests/(.+)': '<rootDir>/tests/$1',
    '@/(.+)': '<rootDir>/src/$1'
  },
  testMatch: ['**/*.spec.ts'],
  roots: [
    '<rootDir>/src',
    '<rootDir>/tests'
  ],
  transform: {
    '\\.ts$': 'ts-jest'
  },
  clearMocks: true,
  setupFiles: ['dotenv/config']
}
" > jest.config.js 


echo '{
  "compilerOptions": {
    "incremental": true,
    "outDir": "dist",
    "rootDirs": ["src", "tests"],
    "target": "es2021",
    "sourceMap": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "module": "commonjs",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "baseUrl": "src",
    "paths": {
      "@/*": ["*"],
      "@/tests/*": ["../tests/*"]
    },
    "strict": true,
    "noImplicitOverride": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true
  },
  "include": ["src", "tests"]
}' > tsconfig.json

echo '{
  "extends": "./tsconfig.json",
  "exclude": ["tests"]
}' > tsconfig-build.json



yarn add -D typescript @types/node

yarn add -D git-commit-msg-linter

yarn add -D jest ts-jest @types/jest


yarn add -D \
  eslint@^7.12.1 \
  eslint-plugin-promise@^5.0.0 \
  eslint-plugin-import@^2.22.1 \
  eslint-plugin-node@^11.1.0 \
  @typescript-eslint/eslint-plugin@^4.0.1 \
  eslint-config-standard-with-typescript@latest

yarn add -D lint-staged

yarn add -D husky 

npx husky add .husky/pre-commit "npm pre-commit"

yarn add module-alias

echo "describe('test', () => {
  it('it test', () => {
    expect(1).toBe(1)
  })
})" > test/index.spec.ts

echo "import { addAlias } from 'module-alias'
import { resolve } from 'path'

addAlias('@', resolve('dist'))
" > src/main/config/moduleAlias.ts 

echo "export * from './moduleAlias'
" > src/main/config/index.ts 

git add . 
git commit -m "chore: add initial files by script"

echo "Everything done!"