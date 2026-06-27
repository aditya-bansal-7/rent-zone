"use client";

import { useState, useEffect } from "react";
import { Wand2, Eye } from "lucide-react";
import { adminService } from "@/services/admin";
import { formatDate, formatRelativeTime } from "@/lib/utils";

export default function TryOnsPage() {
  const [tryOns, setTryOns] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);

  const fetchTryOns = async () => {
    setLoading(true);
    try {
      const res = await adminService.tryons.list({ page, limit: 10 });
      setTryOns(res.tryOns);
      setTotal(res.total);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchTryOns(); }, [page]);

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-gray-900">Virtual Try-Ons</h2>
        <p className="text-sm text-gray-500 mt-1">Monitor AI-generated virtual try-on results.</p>
      </div>

      <div className="admin-card">
        <div className="overflow-x-auto">
          {loading ? (
            <div className="flex justify-center py-10"><div className="w-6 h-6 border-2 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>User</th>
                  <th>Product</th>
                  <th>Model</th>
                  <th>Result</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
                {tryOns.map((tryOn) => (
                  <tr key={tryOn.id}>
                    <td className="font-medium text-gray-800">{tryOn.user?.name}</td>
                    <td>
                      <div className="flex items-center gap-2">
                        {tryOn.product?.imageURLs?.[0] && (
                          <img src={tryOn.product.imageURLs[0]} alt="" className="w-8 h-8 rounded-lg object-cover bg-gray-100" />
                        )}
                        <span className="text-gray-700 text-sm">{tryOn.product?.name}</span>
                      </div>
                    </td>
                    <td className="text-gray-500 text-sm">{tryOn.modelUsed || "default"}</td>
                    <td>
                      {tryOn.resultImageURL ? (
                        <a href={tryOn.resultImageURL} target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-1 text-purple-600 text-sm hover:underline">
                          <Eye size={14} /> View
                        </a>
                      ) : (
                        <span className="text-gray-400 text-sm">N/A</span>
                      )}
                    </td>
                    <td className="text-gray-500 text-sm">{formatDate(tryOn.createdAt)}</td>
                  </tr>
                ))}
                {tryOns.length === 0 && (
                  <tr><td colSpan={5} className="text-center py-10 text-gray-500">No try-on requests found.</td></tr>
                )}
              </tbody>
            </table>
          )}
        </div>

        {!loading && total > 0 && (
          <div className="flex justify-between items-center p-4 text-sm text-gray-500 border-t border-gray-50">
            <span>Showing {(page - 1) * 10 + 1} to {Math.min(page * 10, total)} of {total}</span>
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
