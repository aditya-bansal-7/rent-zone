"use client";

import { useState } from "react";
import { Search, Eye, Star, EyeOff, Sparkles, Archive, Trash2, CheckCircle } from "lucide-react";
import Link from "next/link";
import { mockProducts, mockCategories } from "@/lib/mock-data";
import { formatDate, formatCurrency, getInitials, productStatusColors, cn } from "@/lib/utils";
import type { Product } from "@/types";

export default function ProductsPage() {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [categoryFilter, setCategoryFilter] = useState("all");
  const [products, setProducts] = useState<Product[]>(mockProducts);
  const [selectedRows, setSelectedRows] = useState<string[]>([]);

  const filtered = products.filter((p) => {
    const q = search.toLowerCase();
    const matchSearch = p.name.toLowerCase().includes(q) || p.listedBy.name.toLowerCase().includes(q);
    const matchStatus = statusFilter === "all" || p.status === statusFilter;
    const matchCat = categoryFilter === "all" || p.categoryId === categoryFilter;
    return matchSearch && matchStatus && matchCat;
  });

  const toggleRow = (id: string) =>
    setSelectedRows((prev) => prev.includes(id) ? prev.filter((r) => r !== id) : [...prev, id]);

  const handleAction = (id: string, action: string) => {
    setProducts((prev) => prev.map((p) => {
      if (p.id !== id) return p;
      if (action === "approve") return { ...p, status: "active" };
      if (action === "hide") return { ...p, status: "hidden" };
      if (action === "feature") return { ...p, status: "featured" };
      if (action === "archive") return { ...p, status: "archived" };
      return p;
    }));
  };

  return (
    <div className="space-y-5 max-w-[1400px]">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold text-gray-900">Products</h2>
          <p className="text-sm text-gray-500">{products.length} listings on the platform</p>
        </div>
      </div>

      {/* Filters */}
      <div className="admin-card p-4">
        <div className="flex flex-wrap gap-3 items-center">
          <div className="relative flex-1 min-w-[200px]">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input type="text" placeholder="Search by name or seller..." value={search} onChange={(e) => setSearch(e.target.value)} className="form-input pl-9" />
          </div>
          <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="form-select w-auto">
            <option value="all">All Status</option>
            <option value="active">Active</option>
            <option value="featured">Featured</option>
            <option value="hidden">Hidden</option>
            <option value="archived">Archived</option>
          </select>
          <select value={categoryFilter} onChange={(e) => setCategoryFilter(e.target.value)} className="form-select w-auto">
            <option value="all">All Categories</option>
            {mockCategories.map((c) => <option key={c.id} value={c.id}>{c.name} ({c.type})</option>)}
          </select>
          {selectedRows.length > 0 && (
            <div className="flex items-center gap-2 ml-auto">
              <span className="text-xs text-gray-500">{selectedRows.length} selected</span>
              <button className="btn-secondary text-xs py-1.5">Bulk Hide</button>
              <button className="btn-danger text-xs py-1.5">Bulk Delete</button>
            </div>
          )}
        </div>
      </div>

      {/* Table */}
      <div className="admin-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="data-table">
            <thead>
              <tr>
                <th className="w-10">
                  <input type="checkbox" onChange={() => setSelectedRows(selectedRows.length === filtered.length ? [] : filtered.map((p) => p.id))} className="rounded" />
                </th>
                <th>Product</th>
                <th>Category</th>
                <th>Size</th>
                <th>Condition</th>
                <th>Price/day</th>
                <th>Rating</th>
                <th>Owner</th>
                <th>Status</th>
                <th>Listed</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((product) => (
                <tr key={product.id}>
                  <td>
                    <input type="checkbox" checked={selectedRows.includes(product.id)} onChange={() => toggleRow(product.id)} className="rounded" />
                  </td>
                  <td>
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-100 to-violet-100 flex items-center justify-center flex-shrink-0">
                        <span className="text-purple-600 text-lg">👗</span>
                      </div>
                      <div>
                        <p className="font-medium text-gray-800 text-sm">{product.name}</p>
                        <p className="text-xs text-gray-400">{product.occasion}</p>
                      </div>
                    </div>
                  </td>
                  <td>
                    <div className="text-sm text-gray-600">{product.category.name}</div>
                    <div className="text-xs text-gray-400 capitalize">{product.category.type}</div>
                  </td>
                  <td><span className="badge badge-gray">{product.size}</span></td>
                  <td className="capitalize text-gray-600 text-sm">{product.condition.replace("_"," ")}</td>
                  <td className="font-semibold text-gray-800">₹{product.rentPricePerDay}</td>
                  <td>
                    <div className="flex items-center gap-1 text-amber-500">
                      <Star size={13} fill="currentColor" />
                      <span className="text-gray-700 font-medium">{product.rating}</span>
                    </div>
                  </td>
                  <td>
                    <div className="flex items-center gap-2">
                      <div className="w-6 h-6 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 text-[10px] font-bold">
                        {getInitials(product.listedBy.name)}
                      </div>
                      <span className="text-sm text-gray-700">{product.listedBy.name}</span>
                    </div>
                  </td>
                  <td>
                    <span className={`badge ${productStatusColors[product.status]}`}>{product.status}</span>
                  </td>
                  <td className="text-gray-500 text-xs">{formatDate(product.createdAt)}</td>
                  <td>
                    <div className="flex items-center gap-1">
                      <Link href={`/products/${product.id}`} className="p-1.5 rounded-lg hover:bg-purple-50 text-gray-400 hover:text-purple-600 transition-colors" title="View">
                        <Eye size={15} />
                      </Link>
                      {product.status !== "featured" && (
                        <button onClick={() => handleAction(product.id, "feature")} className="p-1.5 rounded-lg hover:bg-purple-50 text-gray-400 hover:text-purple-600 transition-colors" title="Feature">
                          <Sparkles size={15} />
                        </button>
                      )}
                      {product.status === "hidden" || product.status === "archived" ? (
                        <button onClick={() => handleAction(product.id, "approve")} className="p-1.5 rounded-lg hover:bg-emerald-50 text-gray-400 hover:text-emerald-600 transition-colors" title="Approve">
                          <CheckCircle size={15} />
                        </button>
                      ) : (
                        <button onClick={() => handleAction(product.id, "hide")} className="p-1.5 rounded-lg hover:bg-amber-50 text-gray-400 hover:text-amber-500 transition-colors" title="Hide">
                          <EyeOff size={15} />
                        </button>
                      )}
                      <button onClick={() => handleAction(product.id, "archive")} className="p-1.5 rounded-lg hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition-colors" title="Archive">
                        <Archive size={15} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="flex items-center justify-between text-sm text-gray-500">
        <p>Showing {filtered.length} of {products.length} products</p>
        <div className="flex items-center gap-1">
          {["1","2","3"].map((p) => (
            <button key={p} className={cn("w-8 h-8 rounded-lg text-sm font-medium transition-colors", p === "1" ? "bg-purple-600 text-white" : "hover:bg-gray-100 text-gray-600")}>
              {p}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
