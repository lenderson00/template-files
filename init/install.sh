#!/usr/bin/env bash

yarn init -y

git init

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
  clearMocks: true
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

cat <<< $(jq '.scripts += {"clean":"rimraf dist"} + .scripts' package.json ) > package.json
cat <<< $(jq '.scripts += {"build": "npm run clean && tsc -p tsconfig-build.json"} + .scripts' package.json ) > package.json

cat <<< $(jq '.scripts += {"test":"jest --passWithNoTests --no-cache"} + .scripts' package.json ) > package.json
cat <<< $(jq '.scripts += {"test:watch":"npm t -- --watch"} + .scripts' package.json ) > package.json
cat <<< $(jq '.scripts += {"test:staged": "npm t -- --findRelatedTests"} + .scripts' package.json ) > package.json
cat <<< $(jq '.scripts += {"test:coverage":"npm t -- --coverage"} + .scripts' package.json ) > package.json

cat <<< $(jq '.scripts += {"lint": "eslint"} + .scripts' package.json ) > package.json
cat <<< $(jq '.scripts += {"lint:fix":"npm run lint -- --fix"} + .scripts' package.json ) > package.json

yarn add -D typescript @types/node

yarn add -D git-commit-msg-linter

yarn add -D jest ts-jest @types/jest

yarn add rimraf


yarn add -D \
  eslint@^7.12.1 \
  eslint-plugin-promise@^5.0.0 \
  eslint-plugin-import@^2.22.1 \
  eslint-plugin-node@^11.1.0 \
  @typescript-eslint/eslint-plugin@^4.0.1 \
  eslint-config-standard-with-typescript@latest

yarn add -D lint-staged

yarn add -D husky

npx husky install
npx husky add .husky/pre-commit "npx lint-staged"
npx husky add .husky/pre-push "npm run test:coverage"


yarn add module-alias
yarn add -D @types/module-alias

mkdir tests

echo "describe('test', () => {
  it('it test', () => {
    expect(1).toBe(1)
  })
})" > tests/index.spec.ts


mkdir src
mkdir src/main
mkdir src/main/config

echo "import { addAlias } from 'module-alias'
import { resolve } from 'path'

addAlias('@', resolve('dist'))
" > src/main/config/moduleAlias.ts

echo "export * from './moduleAlias'
" > src/main/config/index.ts

git add .
git commit -m "chore: add initial files by script"

cat <<< $(jq '.engines += {"node:": "16.x"} + .engines' package.json ) > package.json

yarn test

echo "Everything done!"
