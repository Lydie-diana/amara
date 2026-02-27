/* eslint-disable */
/**
 * Generated `api` utility.
 *
 * THIS CODE IS AUTOMATICALLY GENERATED.
 *
 * To regenerate, run `npx convex dev`.
 * @module
 */

import type * as addressSuggestions from "../addressSuggestions.js";
import type * as adminStats from "../adminStats.js";
import type * as auditLogs from "../auditLogs.js";
import type * as auth from "../auth.js";
import type * as autoDispatch from "../autoDispatch.js";
import type * as backfillMenuStats from "../backfillMenuStats.js";
import type * as businessRules from "../businessRules.js";
import type * as dispatch from "../dispatch.js";
import type * as drivers from "../drivers.js";
import type * as favorites from "../favorites.js";
import type * as foodCategories from "../foodCategories.js";
import type * as helpers_errors from "../helpers/errors.js";
import type * as helpers_validators from "../helpers/validators.js";
import type * as http from "../http.js";
import type * as locations from "../locations.js";
import type * as menuItems from "../menuItems.js";
import type * as orderStateMachine from "../orderStateMachine.js";
import type * as orders from "../orders.js";
import type * as promotions from "../promotions.js";
import type * as restaurants from "../restaurants.js";
import type * as reviews from "../reviews.js";
import type * as seedData from "../seedData.js";
import type * as storage from "../storage.js";
import type * as users from "../users.js";

import type {
  ApiFromModules,
  FilterApi,
  FunctionReference,
} from "convex/server";

declare const fullApi: ApiFromModules<{
  addressSuggestions: typeof addressSuggestions;
  adminStats: typeof adminStats;
  auditLogs: typeof auditLogs;
  auth: typeof auth;
  autoDispatch: typeof autoDispatch;
  backfillMenuStats: typeof backfillMenuStats;
  businessRules: typeof businessRules;
  dispatch: typeof dispatch;
  drivers: typeof drivers;
  favorites: typeof favorites;
  foodCategories: typeof foodCategories;
  "helpers/errors": typeof helpers_errors;
  "helpers/validators": typeof helpers_validators;
  http: typeof http;
  locations: typeof locations;
  menuItems: typeof menuItems;
  orderStateMachine: typeof orderStateMachine;
  orders: typeof orders;
  promotions: typeof promotions;
  restaurants: typeof restaurants;
  reviews: typeof reviews;
  seedData: typeof seedData;
  storage: typeof storage;
  users: typeof users;
}>;

/**
 * A utility for referencing Convex functions in your app's public API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = api.myModule.myFunction;
 * ```
 */
export declare const api: FilterApi<
  typeof fullApi,
  FunctionReference<any, "public">
>;

/**
 * A utility for referencing Convex functions in your app's internal API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = internal.myModule.myFunction;
 * ```
 */
export declare const internal: FilterApi<
  typeof fullApi,
  FunctionReference<any, "internal">
>;

export declare const components: {};
