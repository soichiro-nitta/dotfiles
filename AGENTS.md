# Global AGENT Guidance

このリポジトリで作業するエージェント向けのグローバル方針です。プロジェクト配下すべてに適用します。

## Language Policy

- 常に日本語で応答してください。
- 回答はわかりやすく簡潔に、箇条書きと箇条書きの入れ子、改行を使用して整理すること。

## 1. コーディング規約（React/TypeScript）

### コンポーネント
- arrow function を使用（function 宣言は原則不使用）
- props は展開しない（不要な `...props` の横流し禁止）かつ、参照は `props.xxx` として行い分割代入は必要最小限に留める
- 型定義は `type` を使用（`interface` は不使用。外部ライブラリとの統合時のみ例外）
- `any` は使用禁止（必要なら明示的な型設計）
- React Hooks は名前付きインポート（`React.useState` は不使用）
- props の型はインラインで記述（再利用時のみ `type` 定義）
- `forwardRef` は使用しない（外部ライブラリとの統合時のみ例外）
- `ref.current` を一時変数に取り出す場合は 1–2 文字の短い変数名（例: `n`, `el`）で保持し、null チェックを行う

### コード構造
- return は最小限（単一 return 推奨）
- 早期リターン禁止・ガードブロック推奨（`if (!cond) return` は使用しない）
- 条件分岐は `&&` を優先（三項は原則不使用。必要時のみ）
- 変数/関数は再利用しないものはインラインで記述
- 一度きりのスタイルオブジェクトはインライン指定
- 一度きりの小関数/定数もインラインで記述
- コンポーネント分割は過剰に行わない（責務が明確な場合のみ）
- ファイル内ローカルのマッピング/補助ロジックは `__` プレフィックスで関数化しファイル最下部に配置

### 一時変数
- 単回利用の一時変数は作らずインライン化
- 再利用や可読性向上の根拠がない一時変数の導入を禁止
- 例外: 値が変わる可能性があるもの（`ref.current`、非同期間の状態など）は安全のため一時変数で保持

### コード品質
- 型定義はインライン化（再利用時のみ `type` 定義）
- 重複パターンはオブジェクトリテラルで統合
- コンポーネントは単一の return 文に収束
- 条件分岐はオブジェクトインデックスで置換できないか検討

## 2. 命名規則

### 基本原則（役割優先・ドメイン後置）
- 役割を先頭に置く（例: state, set, ref, id, key, on/handle, get/add/update/remove）
- ドメイン名はその後ろに続ける（例: `stateUser`, `refSvg`, `idUser`, `onUserClick`）

### 具体例
- useState: `stateXXX`, `setXXX`
- useRef: `refXXX`
- 反復処理コールバック引数は 1–2 文字（`p`, `i`）
- ドメイン関数は動詞ベース（`get`, `getById`, `add`, `update`, `remove`）
- ページ/レイアウトの変数名: ページは `Page`、レイアウトは `Layout`（default export）

## 3. ファイル/フォルダ構成（Next.js App Router）
- `page.tsx` は RSC（"use client" 禁止）
- クライアントコンポーネントは使用箇所と同じフォルダに同居（再利用性がないものはファイル名をアンダーバー始まりで命名）
- 単回利用の子は `_` プレフィックス（例: `_DialogEdit.tsx`）
- カスタムフックのファイル名はアンダーバー命名の対象外
- `app/layout.tsx` は `<main>` ランドマークで `children` をラップ（ページ側では `<main>` 不使用）
- トップページ関連は `app/(home)` に集約
- 最上位レイアウト関連は `app/(layout)` に集約
- キャッシュタグは `app/tag.ts` などに集約し、`TAG` 定数で提供
- `@` はプロジェクトルートのエイリアス

## 4. DOM 操作・Motion 統合
- DOM 操作で try/catch を使わない（存在ガードと型絞り込み）
- 一時的参照は `ref`、横断参照は `id`（`ID.XXX.E()`）
- `@soichiro_nitta/motion` を使用
- RSC では `createId(['BOX', ...])` を `app/id.ts` などで実行し、Client Component では `'use client'` な `app/motion.ts` から `createMotion(ID)` を呼ぶ
- `motion.to('BOX', ...)` のように ID 名リテラルで target を指定（`ID.BOX.N` は DOM 属性用）
- motion の `id` はファイルをまたいで要素を触る必要がある場合にのみ使用し、それ以外は `ref` を渡す
- 非同期アニメーションは同梱の `useEffectAsync(async () => { await motion.to('BOX', ...) }, deps)` で記述し、`void` IIFE や手動での Promise 無視は避ける
- `useEffect` で await が必要な場合は必ず同梱の `useEffectAsync` を使用（`useEffect` に直接 async を渡さない）
- 即時 async IIFE は `(async () => { ... })()` ではなく `motion.run(async () => { ... })` を使用する
- Next.js 16 での完全なサンプルは `motion-rsc-test` リポジトリ（https://github.com/soichiro-nitta/motion-rsc-test）を参照
- ライブラリ更新は `cd /Users/soichiro/Work/motion && pnpm pack` で生成した tarball を利用し、各プロジェクトで `pnpm add ../motion/soichiro_nitta-motion-<version>.tgz --force` で再インストールする（`link:` 依存は使用しない）
- dev 再起動時に `.next/dev/lock` が残る場合は `.next` を削除してから `pnpm dev --hostname 127.0.0.1 --port 3000` を起動
- 典型エラー対処: `useEffectAsync is not a function` → 新しい tarball を再パック＆再インストール / `Module not found: Can't resolve '@soichiro_nitta/motion'` → tarball 再生成して `pnpm add` し直す
- 変化は `transform`/`opacity` に限定（`scale`, `translateY`, `rotate`, `opacity`）
- `motion.delay(sec)` は常に `await` を付けて使用（`setTimeout`/`setInterval` 不使用）
- `motion.set`/`motion.to` へ `transform` 複合値を渡さない（個別キー指定）
- `motion.set` で `transitionDuration` を未指定の場合は自動的に `0s` になる
- 単位付き文字列を使用（例: `'61px'`, `'120deg'`, `'1'`）

## 5. スタイル管理
- 共通スタイルはファイル内ローカルの `__style` に集約
- クラス合成は `class-variance-authority` の `cva`/`cx`
- ページ内共通化は `__style` or `__Component` で対応

## 6. Next.js 固有
- `next/image` を使用しない（標準 `<img>`、`alt` 必須）
- Next.js 16 以降で MCP が利用できる環境では、エラー調査・診断時に必ず Next.js MCP（例: `nextjs_index` → `nextjs_call`）を用いる

## 7. パッケージ管理
- 常に pnpm を使用（`pnpm add`, `pnpm add -D`, `pnpm install`）

## 8. ESLint/Prettier
- ESLint: Flat Config（`eslint.config.mjs`）
- `@next/next/no-img-element` はオフ
- `import/order` でアルファベット昇順・グループ改行
- Hooks: `rules-of-hooks` off / `exhaustive-deps` warn
- TS: `no-explicit-any: warn`, `consistent-type-imports: error`, `no-unused-vars: warn`
- 特殊制約：
  - `**/app/**/page.{js,jsx,ts,tsx}` で "use client" 禁止
  - Client → Server/Page の直 import を禁止
  - TS ファイルから `page.tsx` への直 import を禁止
- Prettier: `prettier-plugin-tailwindcss`、セミコロンなし、シングルクォート、トレイリングカンマあり

## 9. コミットメッセージ
- 日本語、Conventional Commits 推奨（例：`feat: ホームページのヒーローセクションを追加`）

## 10. Convex 命名
- CRUD: `get`, `getById`, `add`, `update`, `remove`
- 関数名にドメイン名を含めない

## 11. キャッシュ/タグ・Server Actions
- `app/tag.ts` などでタグを一元管理し、`TAG` を定数化（例: `export const TAG = { XXX_XXX: (key: string) => \`XXX_XXX:${key}\` } as const`）
- 書き込み処理は Server Actions に集約し、副作用の散在を避ける
- Server Action 成功後は `revalidateTag(TAG.prepGroups(tenantId))` のように関連タグで一覧を最新化する

## 12. ドットファイル運用
- `.zshrc` などドットファイルを更新した場合は `/Users/soichiro/Work/dotfiles` リポジトリも必ず同内容で更新（コミットおよびプッシュ）する
- 上記の反映・コミット・プッシュは指示待ちせず即時実施する
- ルール変更時はまず `/Users/soichiro/.codex/AGENTS.md` を更新し、それを `dotfiles/AGENTS.md` にコピーしてコミット・プッシュする（/.codex が主、dotfiles はバックアップ兼共有）

## 禁止事項
- `page.tsx` に "use client" を付与しない
- 不要な `...props` の横流し禁止
- トップページ専用の要素を `app/` 直下や共通ディレクトリに置かない
- 早期リターン（`if (!cond) return`）を使用しない
- `setTimeout`/`setInterval` 不使用（待機は `motion.delay` に統一）
