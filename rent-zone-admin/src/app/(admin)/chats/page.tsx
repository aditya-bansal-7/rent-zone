"use client";

import { useState } from "react";
import { Search, Flag, Archive, Ban, MessageSquare } from "lucide-react";
import { mockChats } from "@/lib/mock-data";
import { formatRelativeTime, getInitials, cn } from "@/lib/utils";
import type { Chat } from "@/types";

export default function ChatsPage() {
  const [chats, setChats] = useState<Chat[]>(mockChats);
  const [selectedChat, setSelectedChat] = useState<Chat | null>(null);
  const [search, setSearch] = useState("");

  const filtered = chats.filter((c) => {
    const q = search.toLowerCase();
    return c.participants.some((p) => p.name.toLowerCase().includes(q)) ||
      c.product?.name.toLowerCase().includes(q ?? "") ||
      c.lastMessage?.content.toLowerCase().includes(q ?? "");
  });

  const handleFlag = (id: string) => setChats((prev) => prev.map((c) => c.id === id ? { ...c, isFlagged: !c.isFlagged } : c));
  const handleArchive = (id: string) => setChats((prev) => prev.map((c) => c.id === id ? { ...c, isArchived: !c.isArchived } : c));

  return (
    <div className="space-y-5 max-w-[1400px]">
      <div>
        <h2 className="text-xl font-bold text-gray-900">Chat Monitoring</h2>
        <p className="text-sm text-gray-500">{chats.filter((c) => c.isFlagged).length} flagged conversations</p>
      </div>

      <div className="flex gap-4 h-[600px]">
        {/* Chat List */}
        <div className="admin-card flex flex-col w-80 flex-shrink-0">
          <div className="p-4 border-b border-gray-50">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input type="text" placeholder="Search chats..." value={search} onChange={(e) => setSearch(e.target.value)} className="form-input pl-9 text-sm" />
            </div>
          </div>
          <div className="flex-1 overflow-y-auto divide-y divide-gray-50">
            {filtered.map((chat) => (
              <div
                key={chat.id}
                onClick={() => setSelectedChat(chat)}
                className={cn(
                  "p-4 cursor-pointer hover:bg-purple-50/40 transition-colors",
                  selectedChat?.id === chat.id && "bg-purple-50",
                  chat.isFlagged && "border-l-4 border-l-red-400"
                )}
              >
                <div className="flex items-start gap-3">
                  <div className="relative flex-shrink-0">
                    <div className="w-9 h-9 rounded-full bg-gradient-to-br from-purple-400 to-violet-500 flex items-center justify-center text-white text-xs font-bold">
                      {getInitials(chat.participants[0].name)}
                    </div>
                    {chat.isFlagged && (
                      <div className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full border-2 border-white" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-medium text-gray-800 truncate">
                        {chat.participants.map((p) => p.name).join(" & ")}
                      </p>
                      <p className="text-[10px] text-gray-400 flex-shrink-0 ml-1">
                        {chat.lastMessage ? formatRelativeTime(chat.lastMessage.createdAt) : ""}
                      </p>
                    </div>
                    {chat.product && <p className="text-[10px] text-purple-500 font-medium truncate">{chat.product.name}</p>}
                    <p className="text-xs text-gray-400 truncate mt-0.5">{chat.lastMessage?.content}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Chat Detail */}
        <div className="admin-card flex-1 flex flex-col">
          {selectedChat ? (
            <>
              {/* Header */}
              <div className="px-5 py-4 border-b border-gray-50 flex items-center justify-between">
                <div>
                  <p className="font-semibold text-gray-800">
                    {selectedChat.participants.map((p) => p.name).join(" ↔ ")}
                  </p>
                  {selectedChat.product && (
                    <p className="text-xs text-purple-500">re: {selectedChat.product.name}</p>
                  )}
                </div>
                <div className="flex items-center gap-2">
                  {selectedChat.isFlagged && <span className="badge badge-red">Flagged</span>}
                  <button onClick={() => handleFlag(selectedChat.id)} className={cn("p-1.5 rounded-lg transition-colors", selectedChat.isFlagged ? "bg-red-50 text-red-500" : "hover:bg-amber-50 text-gray-400 hover:text-amber-500")}>
                    <Flag size={15} />
                  </button>
                  <button onClick={() => handleArchive(selectedChat.id)} className="p-1.5 rounded-lg hover:bg-gray-100 text-gray-400 transition-colors">
                    <Archive size={15} />
                  </button>
                  <button className="p-1.5 rounded-lg hover:bg-red-50 text-gray-400 hover:text-red-500 transition-colors">
                    <Ban size={15} />
                  </button>
                </div>
              </div>

              {/* Messages */}
              <div className="flex-1 overflow-y-auto p-5 space-y-3 bg-gray-50/40">
                {selectedChat.messages?.map((msg) => {
                  const sender = selectedChat.participants.find((p) => p.id === msg.senderId);
                  const isFirst = selectedChat.participants[0].id === msg.senderId;
                  return (
                    <div key={msg.id} className={cn("flex items-end gap-2", isFirst ? "flex-row" : "flex-row-reverse")}>
                      <div className="w-6 h-6 rounded-full bg-gradient-to-br from-purple-400 to-violet-500 flex items-center justify-center text-white text-[9px] font-bold flex-shrink-0">
                        {getInitials(sender?.name ?? "?")}
                      </div>
                      <div className={cn(
                        "max-w-[70%] px-3.5 py-2.5 rounded-2xl text-sm",
                        isFirst ? "bg-white border border-gray-100 text-gray-700 rounded-bl-sm" : "bg-purple-600 text-white rounded-br-sm"
                      )}>
                        {msg.content}
                        <p className={cn("text-[10px] mt-1 opacity-60")}>{formatRelativeTime(msg.createdAt)}</p>
                      </div>
                    </div>
                  );
                })}
              </div>

              {/* Admin note */}
              <div className="p-4 border-t border-gray-100 bg-amber-50/60">
                <p className="text-xs text-amber-600 font-medium">
                  👁 You are viewing this conversation in admin monitoring mode. No messages can be sent.
                </p>
              </div>
            </>
          ) : (
            <div className="flex-1 flex flex-col items-center justify-center text-center">
              <div className="w-14 h-14 rounded-2xl bg-purple-50 flex items-center justify-center mb-4">
                <MessageSquare className="w-7 h-7 text-purple-300" />
              </div>
              <p className="text-sm font-medium text-gray-600">Select a conversation</p>
              <p className="text-xs text-gray-400 mt-1">Choose a chat from the left to view messages</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
