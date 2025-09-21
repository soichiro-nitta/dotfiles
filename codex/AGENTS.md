# Global AGENT Guidance

## Language Policy

- Always respond in Japanese.（常に日本語で応答してください）

## 基本方針

## 1. コーディング規約（React/TypeScript）

### コンポーネント

- **arrow function を使用**（function 宣言は原則不使用）
- **props は展開しない**（不要な `...props` の横流し禁止）
- **型定義は `type` を使用**（`interface` は不使用。外部ライブラリとの統合時のみ例外）
- **`any` は使用禁止**（必要なら明示的な型設計を行う）
- React Hooks は **名前付きインポート**（`React.useState` などの `React.` プレフィックスは不使用）
- props の型は **インラインで記述**（再利用時のみ `type` を定義）
- **`forwardRef` は使用しない**（外部ライブラリとの統合時のみ例外）
- props は **`props.xxx` として明示的に参照**する（分割代入は必要時のみ最小限）

### コード構造

- **return は最小限に**（単一 return 推奨。複数行は可）
- **早期リターン禁止・ガードブロック推奨**：`if (!cond) return` は使用せず、`if (cond) { /* 処理 */ }` で包む
- 条件分岐は **`&&` を優先**（三項は原則不使用。必要時のみ可）
- 変数/関数は **再利用しないものはインライン**で記述
- 一度きりのスタイルオブジェクトは **インライン**で指定
- 一度きりの小関数/定数も **インライン**で記述
- コンポーネント分割は **過剰に行わない**（責務が明確な場合のみ）
- ファイル内ローカルのマッピング/補助ロジックは **`__` プレフィックス**で関数に切り出し、**ファイル最下部**に配置

### 一時変数の取り扱い

- **単回利用の一時変数は作らずインライン化する**
- 再利用や明確な可読性向上の根拠がない一時変数の導入を禁止
- **例外**: 値が変わる可能性があるもの（`ref.current`、非同期処理間の状態など）は安全のため一時変数で保持

### コード品質基準

- 型定義は **インライン化**（別定義は削除。再利用時のみ `type` 定義）
- 重複パターンは **オブジェクトリテラル**で統合
- コンポーネントは **単一の return 文**に収束
- 条件分岐は **オブジェクトインデックス**で置換できないか検討

## 2. 命名規則

### 基本原則（役割優先・ドメイン後置）

- 役割を先頭に置く（例: state, set, ref, id, key, on/handle, get/add/update/remove）
- ドメイン名はその後ろに続ける（例: `stateUser`, `refSvg`, `idUser`, `onUserClick`）

### 具体的な命名

- `useState`: `stateXXX`, `setXXX`（リアクティブな値であることを明示）
- `useRef`: `refXXX`（カスタムコンポーネントで参照を渡す場合も `refXxx` 形式）
- 反復処理コールバック（forEach/map/reduce など）の引数は **1–2 文字**（例: `p`, `i`）
- ドメイン関数: 動詞ベース（例: `get`, `getById`, `add`, `update`, `remove`）
- ページ/レイアウトの変数名: ページは **`Page`**、レイアウトは **`Layout`** に統一（default export）

## 3. ファイル/フォルダ構成

### App Router の構成

- 各ページ配下構成（RSC + Client 分離）
- `page.tsx` は RSC のままに保つ（"use client" は付与しない）
- クライアント側ロジックは `_Client/` へ分離
- 1 回しか使わない子は **`_` プレフィックス**（例: `_DialogEdit.tsx`）

### レイアウト（トップレベル）

- `app/layout.tsx` は `<main>` ランドマークで `children` をラップ
- `<main>` はアプリ全体で一意。ページ（`page.tsx`）側では `<main>` を使用しない
- トップページ関連は `app/(home)` に集約

### 命名・エクスポート

- コンポーネント名はパスカルケース
- 単回利用の子は `_` プレフィックスを付ける

### import / エイリアス

- `@` は **プロジェクトルート**を指す（`tsconfig.json` の `paths` に準拠）
- React Hooks は **名前付きインポート**（例: `import { useEffect } from "react";`）

## 4. DOM 操作・Motion 統合ルール

### DOM 操作で try/catch を使わない

- DOM 操作時に `try { … } catch { … }` は使用しない
- 代わりにガード節での存在確認（例: `if (el) { /* 処理 */ }`）
- 型の絞り込み（`useRef<HTMLElement | null>` などの適切な型）
- 例外を握りつぶすような `catch {}` は禁止

### DOM 参照ポリシー（ID と ref の使い分け）

- 単一コンポーネント内のみで完結する一時的な参照: React の `ref` を使用
- 複数回使う/ページやコンポーネントをまたいで参照・制御する要素: `id`（`app/motion.ts` の ID 管理）を使用
- 記法ルール: `ref.current` は値が変わる可能性があるため、必ず 1–2 文字の一時変数に代入してから null チェック・使用する

### Motion API 利用規約

- `@soichiro_nitta/motion` を使用
- 変化は基本 `transform`/`opacity`（例: `scale`, `translateY`, `rotate`, `opacity`）に限定
- `motion.delay(sec)` は「待機のみ」を行う。常に `await` を付けて非同期フロー内で使用
- `setTimeout`/`setInterval` は使用しない（待機は `motion.delay` に統一）

### Motion のプロパティ指定ルール

- `motion.set` / `motion.to` に、CSS 複合プロパティの `transform` は渡さない
- 変形は必ず個別キーで指定（`translateX`, `translateY`, `scale`, `rotate` など）
- 数値・角度・長さは単位付きの文字列で指定（例: `'61px'`, '120deg'`, `'1'`）

### Motion の ID 定義と要素アクセス

- Motion の ID 管理と DOM 要素アクセスは `ID.XXX.E()` を用いる
- `querySelector` / `getElementById` 等の直接参照は原則使用しない
- 存在ガード: DOM 操作前に `const el = ID.XXX.E(); if (el) { /* 処理 */ }` でガード節を使用

## 5. スタイル管理

### コンポーネント内共通スタイル

- 共通スタイルはファイル内ローカルの `__style` オブジェクトに集約
- `__style` の各プロパティ名は簡潔に（例: `img`, `wrap`, `title`, `desc`）
- クラス合成は `class-variance-authority` の `cva` / `cx` を使用
- `cx` の条件分岐はオブジェクト記法を用いる

### ページ内共通化の方針

- スタイルのみを切り出す場合: ファイルローカルの `__style` オブジェクトに `cva` で定義
- 構造やロジックごと共通化する場合: ページ内ローカルコンポーネント `__Component` を作成

## 6. Next.js 固有ルール

### next/image を使用しない

- Next.js の `next/image` を使用しない
- 代わりに標準の `<img>` を使用
- アクセシビリティのため、`alt` は必須

## 7. パッケージ管理

### パッケージマネージャ（pnpm 固定）

- このワークスペースでは **常に pnpm** を使用
- npm / yarn は使用しない
- 依存追加は `pnpm add`、開発依存は `pnpm add -D`、インストールは `pnpm install`

## 8. ESLint/Prettier 設定方針

### ESLint

- ESLint は Flat Config（`eslint.config.mjs`）を使用
- `@next/next/no-img-element` はオフ
- import 並び順は `import/order` でアルファベット昇順、グループ単位に改行
- React Hooks の `rules-of-hooks` は off、`exhaustive-deps` は warn
- TypeScript は `no-explicit-any: warn`、`consistent-type-imports: error`、`no-unused-vars: warn`

### 特殊制約ルール

- `**/app/**/page.{js,jsx,ts,tsx}` では `"use client"` を禁止（RSC 保持）
- Client → Server/Page の直 import を禁止
- TS ファイルから `page.tsx` への直 import を禁止

### Prettier

- `prettier-plugin-tailwindcss` を使用
- セミコロンなし、シングルクォート使用、トレイリングカンマあり

## 9. コミットメッセージ

### 日本語でのコミットメッセージ

- コミットメッセージは **原則すべて日本語** で記述
- 形式は **Conventional Commits** を推奨：`type(scope)?: subject`
- `subject` は **日本語で簡潔に**（末尾の句点は不要、50 文字目安）
- 例：`feat: ホームページのヒーローセクションを追加`

## 10. Convex 命名規則

- CRUD: `get`, `getById`, `add`, `update`, `remove`
- 関数名に **ドメイン名は含めない**（例: `api.transactions.updateStatus` のように使用）

## 禁止事項

- `page.tsx` に "use client" を付与しない
- 不要な `...props` の横流しを行わない
- トップページ専用の要素を `app/` 直下や共通ディレクトリに置かない
- ページ（`page.tsx`）で `<main>` を使用しない
- 早期リターン（`if (!cond) return`）を使用しない
- `setTimeout`/`setInterval` は使用しない（待機は `motion.delay` に統一）
