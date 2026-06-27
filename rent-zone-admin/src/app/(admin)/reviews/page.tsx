"use client";

import { useState, useEffect } from "react";
import { Search, Star, Flag, Trash2 } from "lucide-react";
import { adminService } from "@/services/admin";
import { formatDate, getInitials } from "@/lib/utils";

export default function ReviewsPage() {
  const [reviews, setReviews] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [flaggedOnly, setFlaggedOnly] = useState(false);

  const fetchReviews = async () => {
    setLoading(true);
    try {
      const res = await adminService.reviews.list({
        page, limit: 10,
        isFlagged: flaggedOnly ? true : undefined,
      });
      setReviews(res.reviews);
      setTotal(res.total);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchReviews(); }, [page, flaggedOnly]);

  const handleFlag = async (id: string) => {
    try { await adminService.reviews.flag(id); fetchReviews(); } catch (err) { console.error(err); }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Delete this review?")) return;
    try { await adminService.reviews.delete(id); fetchReviews(); } catch (err) { console.error(err); }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Reviews</h2>
          <p className="text-sm text-gray-500 mt-1">Moderate user reviews and flag inappropriate content.</p>
        </div>
        <label className="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
          <input type="checkbox" checked={flaggedOnly} onChange={(e) => { setFlaggedOnly(e.target.checked); setPage(1); }} className="accent-purple-600" />
          Show flagged only
        </label>
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
                  <th>Rating</th>
                  <th>Content</th>
                  <th>Date</th>
                  <th className="text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {reviews.map((review) => (
                  <tr key={review.id}>
                    <td>
                      <div className="flex items-center gap-2">
                        <div className="w-7 h-7 rounded-full bg-purple-100 flex items-center justify-center text-purple-700 text-[10px] font-bold">
                          {getInitials(review.user?.name || "U")}
                        </div>
                        <span className="text-sm font-medium text-gray-800">{review.user?.name}</span>
                      </div>
                    </td>
                    <td className="text-gray-600 text-sm">{review.product?.name}</td>
                    <td>
                      <div className="flex items-center gap-0.5">
                        {[...Array(5)].map((_, i) => (
                          <Star key={i} size={12} className={i < review.rating ? "text-amber-400 fill-amber-400" : "text-gray-200"} />
                        ))}
                      </div>
                    </td>
                    <td className="text-gray-600 text-sm max-w-[300px] truncate">{review.content}</td>
                    <td className="text-gray-500 text-sm">{formatDate(review.createdAt)}</td>
                    <td className="text-right">
                      <div className="flex items-center justify-end gap-1">
                        {review.isFlagged ? (
                          <span className="badge badge-red text-xs">Flagged</span>
                        ) : (
                          <button onClick={() => handleFlag(review.id)} className="p-1.5 text-gray-400 hover:text-amber-500 hover:bg-amber-50 rounded-lg transition-colors" title="Flag">
                            <Flag size={16} />
                          </button>
                        )}
                        <button onClick={() => handleDelete(review.id)} className="p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors" title="Delete">
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
                {reviews.length === 0 && (
                  <tr><td colSpan={6} className="text-center py-10 text-gray-500">No reviews found.</td></tr>
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
