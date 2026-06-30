"use client";

import { useState, useEffect } from "react";
import { Search, Filter, MoreHorizontal, Star, PackageX, Archive, CheckCircle, EyeOff } from "lucide-react";
import { adminService } from "@/services/admin";
import { formatCurrency, productStatusColors } from "@/lib/utils";
import Link from "next/link";

export default function ProductsPage() {
  const [products, setProducts] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("all");

  const fetchProducts = async () => {
    setLoading(true);
    try {
      const res = await adminService.products.list({ page, limit: 10, search, status: status !== "all" ? status : undefined });
      setProducts(res.products);
      setTotal(res.total);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProducts();
  }, [page, search, status]);

  const handleAction = async (id: string, action: "approve" | "hide" | "feature" | "archive") => {
    try {
      await adminService.products[action](id);
      fetchProducts();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Products</h2>
          <p className="text-sm text-gray-500 mt-1">Manage listings, moderation, and featuring.</p>
        </div>
      </div>

      <div className="admin-card p-4">
        <div className="flex flex-col sm:flex-row justify-between gap-4 mb-4">
          <div className="relative max-w-md w-full">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search listings by name..."
              className="w-full pl-9 pr-4 py-2 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400"
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            />
          </div>
          <div className="flex items-center gap-3">
            <select
              className="text-sm bg-gray-50 border border-gray-200 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-purple-500/30"
              value={status}
              onChange={(e) => { setStatus(e.target.value); setPage(1); }}
            >
              <option value="all">All Statuses</option>
              <option value="active">Active</option>
              <option value="hidden">Hidden</option>
              <option value="featured">Featured</option>
              <option value="archived">Archived</option>
            </select>
            <button className="btn-secondary whitespace-nowrap">
              <Filter size={16} /> Filters
            </button>
          </div>
        </div>

        <div className="overflow-x-auto">
          {loading ? (
             <div className="flex justify-center py-10"><div className="w-6 h-6 border-2 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>Product</th>
                  <th>Owner</th>
                  <th>Category</th>
                  <th>Price/day</th>
                  <th>Status</th>
                  <th className="text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {products.map((product) => (
                  <tr key={product.id}>
                    <td>
                      <div className="flex items-center gap-3">
                        <img 
                          src={product.imageURLs?.[0] || 'https://via.placeholder.com/40'} 
                          alt="" 
                          className="w-10 h-10 rounded-lg object-cover bg-gray-100"
                        />
                        <div>
                          <Link href={`/products/${product.id}`} className="font-medium text-gray-900 hover:text-purple-600 transition-colors">
                            {product.name}
                          </Link>
                          <div className="flex items-center gap-1.5 text-xs text-amber-500 mt-0.5">
                            <Star size={12} className="fill-current" />
                            <span className="text-gray-600 font-medium">{product.rating}</span>
                            <span className="text-gray-400">({product._count?.reviews || 0} reviews)</span>
                          </div>
                        </div>
                      </div>
                    </td>
                    <td>
                      <div className="flex items-center gap-2">
                        <div className="w-6 h-6 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center text-[10px] font-bold">
                          {product.listedBy.name.charAt(0)}
                        </div>
                        <span className="text-sm text-gray-700">{product.listedBy.name}</span>
                      </div>
                    </td>
                    <td className="text-gray-600 capitalize">{product.category.name}</td>
                    <td className="font-semibold text-gray-800">{formatCurrency(product.rentPricePerDay)}</td>
                    <td>
                      <span className={`badge ${productStatusColors[product.status] || 'badge-gray'}`}>
                        {product.status || 'active'}
                      </span>
                    </td>
                    <td className="text-right">
                      <div className="flex items-center justify-end gap-2">
                        {product.status !== 'active' && (
                          <button onClick={() => handleAction(product.id, "approve")} className="p-1.5 text-gray-400 hover:text-green-500 hover:bg-green-50 rounded-lg transition-colors" title="Approve">
                            <CheckCircle size={18} />
                          </button>
                        )}
                        {product.status !== 'hidden' && (
                          <button onClick={() => handleAction(product.id, "hide")} className="p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors" title="Hide">
                            <EyeOff size={18} />
                          </button>
                        )}
                        {product.status !== 'archived' && (
                          <button onClick={() => handleAction(product.id, "archive")} className="p-1.5 text-gray-400 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors" title="Archive">
                            <Archive size={18} />
                          </button>
                        )}
                        <button className="p-1.5 text-gray-400 hover:text-purple-600 hover:bg-purple-50 rounded-lg transition-colors">
                          <MoreHorizontal size={18} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
                {products.length === 0 && (
                  <tr><td colSpan={6} className="text-center py-10 text-gray-500">No products found.</td></tr>
                )}
              </tbody>
            </table>
          )}
        </div>
        
        {/* Basic Pagination UI */}
        {!loading && total > 0 && (
          <div className="flex justify-between items-center mt-4 text-sm text-gray-500 px-2">
            <span>Showing {(page - 1) * 10 + 1} to {Math.min(page * 10, total)} of {total} products</span>
            <div className="flex gap-2">
              <button disabled={page === 1} onClick={() => setPage(p => p - 1)} className="px-3 py-1 border rounded disabled:opacity-50 hover:bg-gray-50">Prev</button>
              <button disabled={page * 10 >= total} onClick={() => setPage(p => p + 1)} className="px-3 py-1 border rounded disabled:opacity-50 hover:bg-gray-50">Next</button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
